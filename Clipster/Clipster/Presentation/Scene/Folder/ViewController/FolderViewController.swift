import ReactorKit
import UIKit

final class FolderViewController: UIViewController, View {
    typealias Reactor = FolderReactor

    var disposeBag = DisposeBag()

    private let folderView = FolderView()
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
        view = folderView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        reactor?.action.onNext(.viewWillAppear)
    }

    func bind(reactor: FolderReactor) {
        bindAction(to: reactor)
        bindState(from: reactor)
        bindRoute(from: reactor)
    }
}

private extension FolderViewController {
    func bindAction(to reactor: FolderReactor) {
        folderView.action
            .bind { [weak self] action in
                guard let self else { return }

                switch action {
                case .didTapBackButton:
                    navigationController?.popViewController(animated: true)
                case .didTapAddFolderButton:
                    reactor.action.onNext(.didTapAddFolderButton)
                case .didTapAddClipButton:
                    reactor.action.onNext(.didTapAddClipButton)
                case .didTapCell(let indexPath):
                    reactor.action.onNext(.didTapCell(indexPath))
                case .didTapDetailButton(let indexPath):
                    reactor.action.onNext(.didTapDetailButton(indexPath))
                case .didTapEditButton(let indexPath):
                    reactor.action.onNext(.didTapEditButton(indexPath))
                case .didTapDeleteButton(let indexPath, let title):
                    presentDeleteAlert(title: title) {
                        reactor.action.onNext(.didTapDeleteButton(indexPath))
                    }
                }
            }
            .disposed(by: disposeBag)
    }

    func bindState(from reactor: FolderReactor) {
        reactor.state
            .observe(on: MainScheduler.instance)
            .map(\.currentFolderTitle)
            .distinctUntilChanged()
            .bind { [weak self] title in
                guard let self else { return }
                folderView.setDisplay(title: title)
            }
            .disposed(by: disposeBag)

        typealias Display = ([FolderDisplay], [ClipDisplay])
        reactor.state
            .observe(on: MainScheduler.instance)
            .map { ($0.folders, $0.clips) }
            .distinctUntilChanged { (lhs: Display, rhs: Display) in
                lhs.0 == rhs.0 && lhs.1 == rhs.1
            }
            .subscribe { [weak self] folders, clips in
                guard let self else { return }
                folderView.setDisplay(folders: folders, clips: clips)
            }
            .disposed(by: disposeBag)

        reactor.state
            .observe(on: MainScheduler.instance)
            .map(\.isEmptyStateViewHidden)
            .distinctUntilChanged()
            .bind { [weak self] isHidden in
                guard let self else { return }
                folderView.setDisplay(isHidden: isHidden)
            }
            .disposed(by: disposeBag)

        reactor.pulse(\.$phase)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] phase in
                guard let self else { return }

                switch phase {
                case .idle, .success:
                    folderView.setLoading(false)
                case .loading:
                    folderView.setLoading(true)
                case .error(let message):
                    presentErrorAlert(message: message)
                }
            }
            .disposed(by: disposeBag)
    }

    func bindRoute(from reactor: FolderReactor) {
        reactor.pulse(\.$route)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .bind { [weak self] route in
                guard let self else { return }

                switch route {
                case .editClipViewForAdd(let folder):
                    coordinator?.showAddClip(folder: folder)
                case .editClipViewForEdit(let clip):
                    coordinator?.showEditClip(clip: clip)
                case .editFolderView(let parentFolder, let folder):
                    coordinator?.showEditFolder(parentFolder: parentFolder, folder: folder)
                case .folderView(let folder):
                    coordinator?.showFolder(folder: folder)
                case .clipDetailView(let clip):
                    coordinator?.showDetailClip(clip: clip)
                case .webView(let url):
                    coordinator?.showWebView(url: url)
                }
            }
            .disposed(by: disposeBag)
    }
}

extension FolderViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
