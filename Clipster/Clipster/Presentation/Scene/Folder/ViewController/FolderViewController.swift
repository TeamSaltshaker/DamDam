import ReactorKit
import SafariServices
import UIKit

final class FolderViewController: UIViewController, View {
    typealias Reactor = FolderReactor

    var disposeBag = DisposeBag()
    private let diContainer: DIContainer

    private let folderView = FolderView()

    init(reactor: Reactor, diContainer: DIContainer) {
        self.diContainer = diContainer
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
            .map(\.isEmptyViewHidden)
            .distinctUntilChanged()
            .bind { [weak self] isHidden in
                guard let self else { return }
                folderView.setDisplay(isHidden: isHidden)
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
                    let reactor = diContainer.makeEditClipReactor(folder: folder)
                    let vc = EditClipViewController(reactor: reactor, diContainer: diContainer)
                    navigationController?.pushViewController(vc, animated: true)
                case .editClipViewForEdit(let clip):
                    let reactor = diContainer.makeEditClipReactor(clip: clip)
                    let vc = EditClipViewController(reactor: reactor, diContainer: diContainer)
                    navigationController?.pushViewController(vc, animated: true)
                case .editFolderView(let parentFolder, let folder):
                    let vm = diContainer.makeEditFolderReactor(parentFolder: parentFolder, folder: folder)
                    let vc = EditFolderViewController(reactor: vm, diContainer: diContainer)
                    navigationController?.pushViewController(vc, animated: true)
                case .folderView(let folder):
                    let reactor = diContainer.makeFolderReactor(folder: folder)
                    let vc = FolderViewController(reactor: reactor, diContainer: diContainer)
                    navigationController?.pushViewController(vc, animated: true)
                case .clipDetailView(let clip):
                    let vm = diContainer.makeClipDetailReactor(clip: clip)
                    let vc = ClipDetailViewController(reactor: vm, diContainer: diContainer)
                    navigationController?.pushViewController(vc, animated: true)
                case .webView(let url):
                    let vc = SFSafariViewController(url: url)
                    present(vc, animated: true)
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
