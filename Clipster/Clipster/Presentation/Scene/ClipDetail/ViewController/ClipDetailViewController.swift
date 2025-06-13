import RxSwift
import UIKit

final class ClipDetailViewController: UIViewController {
    private let viewModel: ClipDetailViewModel
    private let diContainer: DIContainer
    private let disposeBag = DisposeBag()

    private let clipDetailView = ClipDetailView()

    init(viewModel: ClipDetailViewModel, diContainer: DIContainer) {
        self.viewModel = viewModel
        self.diContainer = diContainer
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = clipDetailView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        viewModel.action.accept(.viewWillAppear)
    }
}

private extension ClipDetailViewController {
    func configure() {
        setBindings()
    }

    func setBindings() {
        let state = viewModel.state.share(replay: 1)

        state
            .map { (clip: $0.clipDisplay, folder: $0.folderDisplay) }
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] (clip, folder) in
                guard let folder else { return }

                self?.clipDetailView.setDisplay(clip, folder: folder)
                self?.clipDetailView.setInteraction(enabled: false)
            }
            .disposed(by: disposeBag)

        state
            .map { $0.isLoading }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] isLoading in
                self?.clipDetailView.setLoading(isLoading)
            }
            .disposed(by: disposeBag)

        state
            .map { $0.isProcessingDelete }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] isProcessing in
                guard let self else { return }

                self.clipDetailView.editButton.isEnabled = !isProcessing
                self.clipDetailView.deleteButton.isEnabled = !isProcessing
                self.clipDetailView.alpha = isProcessing ? 0.5 : 1.0
                self.navigationController?.navigationBar.isUserInteractionEnabled = !isProcessing
            }
            .disposed(by: disposeBag)

        state
            .map { $0.showDeleteConfirmation }
            .distinctUntilChanged()
            .filter { $0 }
            .withLatestFrom(state.map { $0.clipDisplay.urlMetadata.title })
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] title in
                guard let self else { return }

                self.presentDeleteAlert(
                    title: title,
                    onCancel: {
                        self.viewModel.action.accept(.deleteCanceled)
                    },
                    onConfirm: {
                        self.viewModel.action.accept(.deleteConfirmed)
                    }
                )
            }
            .disposed(by: disposeBag)

        state
            .compactMap { $0.errorMessage }
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] message in
                let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
            .disposed(by: disposeBag)

        state
            .map { $0.shouldNavigateToEdit }
            .distinctUntilChanged()
            .filter { $0 }
            .withLatestFrom(state)
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] state in
                guard let self else { return }

                let vm = self.diContainer.makeEditClipViewModel(clip: state.clip)
                let vc = EditClipViewController(viewModel: vm, diContainer: self.diContainer)
                self.navigationController?.pushViewController(vc, animated: true)
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

        clipDetailView.backButton.rx.tap
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)

        clipDetailView.editButton.rx.tap
            .map { ClipDetailAction.editButtonTapped }
            .bind(to: viewModel.action)
            .disposed(by: disposeBag)

        clipDetailView.deleteButton.rx.tap
            .map { ClipDetailAction.deleteButtonTapped }
            .bind(to: viewModel.action)
            .disposed(by: disposeBag)
    }
}

extension ClipDetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
