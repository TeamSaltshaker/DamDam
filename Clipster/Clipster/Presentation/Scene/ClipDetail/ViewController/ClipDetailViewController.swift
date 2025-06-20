import ReactorKit
import RxSwift
import UIKit

final class ClipDetailViewController: UIViewController, View {
    typealias Reactor = ClipDetailReactor

    var disposeBag = DisposeBag()
    private let clipDetailView = ClipDetailView()
    private weak var coordinator: HomeCoordinator?

    init(reactor: Reactor, coordinator: HomeCoordinator) {
        self.coordinator = coordinator
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
        typealias Display = (clip: ClipDisplay, folder: FolderDisplay?)

        reactor.state
            .map { state -> Display in
                (clip: state.clipDisplay, folder: state.folderDisplay)
            }
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
            .map { state -> Display in
                (clip: state.clipDisplay, folder: state.folderDisplay)
            }
            .distinctUntilChanged { (lhs: Display, rhs: Display) in
                lhs.clip == rhs.clip && lhs.folder == rhs.folder
            }
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] (clip, folder) in
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
                    coordinator?.showEditClip(clip: clip)
                case .showDeleteConfirmation(let title):
                    self.presentDeleteAlert(title: title) { [weak reactor] in
                        reactor?.action.onNext(.deleteConfirmed)
                    }
                }
            }
            .disposed(by: disposeBag)
    }
}

private extension ClipDetailViewController {
    func presentAlert(message: String) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

extension ClipDetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
