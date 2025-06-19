import ReactorKit
import RxSwift
import UIKit

final class ClipDetailViewController: UIViewController, View {
    typealias Reactor = ClipDetailReactor
    private let diContainer: DIContainer
    var disposeBag = DisposeBag()

    private let clipDetailView = ClipDetailView()

    init(reactor: Reactor, diContainer: DIContainer) {
        self.diContainer = diContainer
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = clipDetailView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        reactor?.action.onNext(.viewWillAppear)
    }

    func bind(reactor: Reactor) {
        bindAction(to: reactor)
        bindState(from: reactor)
        bindRoute(from: reactor)
    }
}

private extension ClipDetailViewController {
    func bindAction(to reactor: Reactor) {
        clipDetailView.backButton.rx.tap
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)

        clipDetailView.editButton.rx.tap
            .map { .editButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        clipDetailView.deleteButton.rx.tap
            .map { .deleteButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }

    func bindState(from reactor: Reactor) {
        reactor.state
            .map { (clip: $0.clipDisplay, folder: $0.folderDisplay) }
            .filter { $0.folder != nil }
            .take(1)
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] (clip, folder) in
                guard let folder else { return }
                self?.clipDetailView.setDisplay(clip, folder: folder)
            }
            .disposed(by: disposeBag)

        reactor.state
            .skip(1)
            .map { (clip: $0.clip, clipDisplay: $0.clipDisplay, folderDisplay: $0.folderDisplay) }
            .distinctUntilChanged { $0.clip.updatedAt == $1.clip.updatedAt }
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] (_, clip, folder) in
                guard let folder else { return }
                self?.clipDetailView.setDisplay(clip, folder: folder)
            }
            .disposed(by: disposeBag)

        reactor.pulse(\.$phase)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] phase in
                guard let self = self else { return }
                switch phase {
                case .idle:
                    break
                case .loading:
                    break
                case .success:
                    self.navigationController?.popViewController(animated: true)
                case .error(let message):
                    self.presentAlert(message: message)
                }
            }
            .disposed(by: disposeBag)
    }

    func bindRoute(from reactor: Reactor) {
        reactor.pulse(\.$route)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] route in
                guard let self else { return }
                switch route {
                case .showEditClip(let clip):
                    let vm = self.diContainer.makeEditClipViewModel(clip: clip)
                    let vc = EditClipViewController(viewModel: vm, diContainer: self.diContainer)
                    self.navigationController?.pushViewController(vc, animated: true)
                case .showDeleteConfirmation(let title):
                    self.presentDeleteAlert(title: title) {
                        reactor.action.onNext(.deleteConfirmed)
                    }
                }
            }
            .disposed(by: disposeBag)
    }
}

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

                let reactor = self.diContainer.makeEditClipReactor(clip: state.clip)
                let vc = EditClipViewController(reactor: reactor, diContainer: self.diContainer)
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
