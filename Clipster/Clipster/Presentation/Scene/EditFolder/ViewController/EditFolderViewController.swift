import RxCocoa
import RxSwift
import SnapKit
import UIKit

final class EditFolderViewController: UIViewController {
    private let viewModel: EditFolderViewModel
    private let disposeBag = DisposeBag()

    private let backButton = BackButton()
    private let saveButton = SaveButton()
    private let editFolderView = EditFolderView()

    init(viewModel: EditFolderViewModel) {
        self.viewModel = viewModel
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
        setAttributes()
        setBindings()
    }

    func setAttributes() {
        title = "폴더 추가"
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
    }

    func setBindings() {
        viewModel.state
            .map { $0.isSavable }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: saveButton.rx.isEnabled)
            .disposed(by: disposeBag)

        viewModel.state
            .map { $0.isProcessing }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] isProcessing in
                guard let self else { return }
                self.saveButton.isUserInteractionEnabled = !isProcessing
                self.saveButton.alpha = isProcessing ? 0.5 : 1.0
                self.editFolderView.setTextFieldInteraction(enabled: !isProcessing)
            }
            .disposed(by: disposeBag)

        viewModel.state
            .compactMap { $0.alertMessage }
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] message in
                let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
            .disposed(by: disposeBag)

        viewModel.state
            .map { $0.shouldDismiss }
            .distinctUntilChanged()
            .filter { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)

        viewModel.state
            .map { $0.folderTitle }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: editFolderView.folderTitleBinder)
            .disposed(by: disposeBag)

        backButton.rx.tap
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

        saveButton.rx.tap
            .map { EditFolderAction.saveButtonTapped }
            .bind(to: viewModel.action)
            .disposed(by: disposeBag)
    }
}
