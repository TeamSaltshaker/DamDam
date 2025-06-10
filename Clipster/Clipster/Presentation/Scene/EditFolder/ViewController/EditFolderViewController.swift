import RxCocoa
import RxSwift
import SnapKit
import UIKit

final class EditFolderViewController: UIViewController {
    private let viewModel: EditFolderViewModel
    private let diContainer: DIContainer
    private let disposeBag = DisposeBag()

    private let editFolderView = EditFolderView()

    init(viewModel: EditFolderViewModel, diContainer: DIContainer) {
        self.viewModel = viewModel
        self.diContainer = diContainer
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = editFolderView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
}

private extension EditFolderViewController {
    func configure() {
        setBindings()
    }

    func setBindings() {
        let state = viewModel.state.share(replay: 1)

        state
            .map { $0.navigationTitle }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] title in
                self?.editFolderView.commonNavigationView.setTitle(title)
            }
            .disposed(by: disposeBag)

        state
            .map { $0.isSavable }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: editFolderView.saveButton.rx.isEnabled)
            .disposed(by: disposeBag)

        state
            .map { $0.isProcessing }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] isProcessing in
                guard let self else { return }
                self.editFolderView.saveButton.isUserInteractionEnabled = !isProcessing
                self.editFolderView.saveButton.alpha = isProcessing ? 0.5 : 1.0
                self.editFolderView.setTextFieldInteraction(enabled: !isProcessing)
            }
            .disposed(by: disposeBag)

        state
            .compactMap { $0.alertMessage }
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] message in
                let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
            .disposed(by: disposeBag)

        state
            .map { $0.shouldDismiss }
            .distinctUntilChanged()
            .filter { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)

        state
            .map { $0.folderTitle }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: editFolderView.folderTitleBinder)
            .disposed(by: disposeBag)

        editFolderView.backButton.rx.tap
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)

        editFolderView.folderTitleChanges
            .distinctUntilChanged()
            .map { .folderTitleChanged($0) }
            .bind(to: viewModel.action)
            .disposed(by: disposeBag)

        editFolderView.saveButton.rx.tap
            .map { EditFolderAction.saveButtonTapped }
            .bind(to: viewModel.action)
            .disposed(by: disposeBag)
    }
}
