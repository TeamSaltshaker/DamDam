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
        navigationController?.setNavigationBarHidden(true, animated: true)
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
        folderView.didTapBackButton
            .bind { [weak self] in
                guard let self else { return }
                navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)

        folderView.didTapAddFolderButton
            .map { Reactor.Action.didTapAddFolderButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        folderView.didTapAddClipButton
            .map { Reactor.Action.didTapAddClipButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        folderView.didTapCell
            .map { Reactor.Action.didTapCell($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        folderView.didTapDetailButton
            .map { Reactor.Action.didTapDetailButton($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        folderView.didTapEditButton
            .map { Reactor.Action.didTapEditButton($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        folderView.didTapDeleteButton
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] (indexPath, title) in
                guard let self else { return }
                presentDeleteAlert(title: title) { [weak self] in
                    self?.reactor?.action.onNext(.didTapDeleteButton(indexPath))
                }
            }
            .disposed(by: disposeBag)
    }

    func bindState(from reactor: FolderReactor) {
        reactor.state
            .observe(on: MainScheduler.instance)
            .map { $0.currentFolderTitle }
            .bind { [weak self] title in
                guard let self else { return }
                folderView.setDisplay(title: title)
            }
            .disposed(by: disposeBag)

        reactor.state
            .observe(on: MainScheduler.instance)
            .map { ($0.folders, $0.clips) }
            .subscribe { [weak self] folders, clips in
                guard let self else { return }
                folderView.setDisplay(folders: folders, clips: clips)
            }
            .disposed(by: disposeBag)

        reactor.state
            .observe(on: MainScheduler.instance)
            .map { $0.isEmptyViewHidden }
            .bind { [weak self] isHidden in
                guard let self else { return }
                folderView.setDisplay(isEmptyViewHidden: isHidden)
            }
            .disposed(by: disposeBag)
    }

    func bindRoute(from reactor: FolderReactor) {
        reactor.route
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] route in
                guard let self = self else { return }

                switch route {
                case .editClipViewForAdd(let folder):
                    let vm = diContainer.makeEditClipViewModel(folder: folder)
                    let vc = EditClipViewController(viewModel: vm, diContainer: diContainer)
                    navigationController?.pushViewController(vc, animated: true)
                case .editClipViewForEdit(let clip):
                    let vm = diContainer.makeEditClipViewModel(clip: clip)
                    let vc = EditClipViewController(viewModel: vm, diContainer: diContainer)
                    navigationController?.pushViewController(vc, animated: true)
                case .editFolderView(let parentFolder, let folder):
                    let mode: EditFolderMode
                    if let folder = folder {
                        mode = .edit(parentFolder: parentFolder, folder: folder)
                    } else {
                        mode = .add(parentFolder: parentFolder)
                    }
                    let vm = diContainer.makeEditFolderViewModel(mode: mode)
                    let vc = EditFolderViewController(viewModel: vm, diContainer: diContainer)
                    navigationController?.pushViewController(vc, animated: true)
                case .folderView(let folder):
                    let reactor = diContainer.makeFolderReactor(folder: folder)
                    let vc = FolderViewController(reactor: reactor, diContainer: diContainer)
                    navigationController?.pushViewController(vc, animated: true)
                case .clipDetailView(let clip):
                    let vm = diContainer.makeClipDetailViewModel(clip: clip)
                    let vc = ClipDetailViewController(viewModel: vm, diContainer: diContainer)
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
