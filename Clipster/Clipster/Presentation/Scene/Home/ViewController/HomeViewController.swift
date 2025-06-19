import ReactorKit
import SafariServices
import UIKit

final class HomeViewController: UIViewController, View {
    typealias Reactor = HomeReactor

    var disposeBag = DisposeBag()
    private let homeView = HomeView()
    private let diContainer: DIContainer

    init(reactor: Reactor, diContainer: DIContainer) {
        self.diContainer = diContainer
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = homeView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reactor?.action.onNext(.viewWillAppear)
    }

    func bind(reactor: Reactor) {
        bindAction(to: reactor)
        bindState(from: reactor)
        bindRoute(from: reactor)
    }
}

private extension HomeViewController {
    func bindAction(to reactor: Reactor) {
        homeView.action
            .bind { [weak self] action in
                switch action {
                case .tapAddFolder:
                    reactor.action.onNext(.tapAddFolder)
                case .tapAddClip:
                    reactor.action.onNext(.tapAddClip)
                case .tapCell(let indexPath):
                    reactor.action.onNext(.tapCell(indexPath))
                case .detail(let indexPath):
                    reactor.action.onNext(.tapDetail(indexPath))
                case .edit(let indexPath):
                    reactor.action.onNext(.tapEdit(indexPath))
                case .delete(let indexPath, let title):
                    self?.presentDeleteAlert(title: title) {
                        reactor.action.onNext(.tapDelete(indexPath))
                    }
                case .showAllClips:
                    reactor.action.onNext(.tapShowAllClips)
                }
            }
            .disposed(by: disposeBag)
    }

    func bindState(from reactor: Reactor) {
        reactor.state
            .compactMap { $0.homeDisplay }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] display in
                self?.homeView.setDisplay(display)
            }
            .disposed(by: disposeBag)

        reactor.pulse(\.$phase)
            .observe(on: MainScheduler.instance)
            .bind { [weak self] phase in
                guard let self else { return }

                switch phase {
                case .loading:
                    homeView.showLoading()
                case .success:
                    homeView.hideLoading()
                case .error(let message):
                    let alert = UIAlertController(title: "에러", message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default))
                    present(alert, animated: true)
                case .idle:
                    break
                }
            }
            .disposed(by: disposeBag)
    }

    func bindRoute(from reactor: Reactor) {
        reactor.pulse(\.$route)
            .compactMap { $0 }
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .bind { [weak self] route in
                guard let self else { return }

                switch route {
                case .showAddClip(let folder):
                    let reactor = diContainer.makeEditClipReactor(folder: folder)
                    let vc = EditClipViewController(
                        reactor: reactor,
                        diContainer: diContainer
                    )
                    navigationController?.pushViewController(vc, animated: true)
                case .showAddFolder:
                    let reactor = self.diContainer.makeEditFolderReactor(parentFolder: nil, folder: nil)
                    let vc = EditFolderViewController(
                        reactor: reactor,
                        diContainer: self.diContainer
                    )
                    self.navigationController?.pushViewController(vc, animated: true)
                case .showWebView(let url):
                    let vc = SFSafariViewController(url: url)
                    present(vc, animated: true)
                case .showFolder(let folder):
                    let reactor = diContainer.makeFolderReactor(folder: folder)
                    let vc = FolderViewController(reactor: reactor, diContainer: diContainer)
                    navigationController?.pushViewController(vc, animated: true)
                case .showDetailClip(let clip):
                    let reactor = self.diContainer.makeClipDetailReactor(clip: clip)
                    let vc = ClipDetailViewController(
                        reactor: reactor,
                        diContainer: self.diContainer
                    )
                    self.navigationController?.pushViewController(vc, animated: true)
                case .showEditClip(let clip):
                    let reactor = diContainer.makeEditClipReactor(clip: clip)
                    let vc = EditClipViewController(
                        reactor: reactor,
                        diContainer: diContainer
                    )
                    navigationController?.pushViewController(vc, animated: true)
                case .showEditFolder(let folder):
                    let reactor = self.diContainer.makeEditFolderReactor(
                        parentFolder: nil,
                        folder: folder
                    )
                    let vc = EditFolderViewController(
                        reactor: reactor,
                        diContainer: self.diContainer
                    )
                    self.navigationController?.pushViewController(vc, animated: true)
                case .showUnvisitedClipList(let clips):
                    let reactor = diContainer.makeUnvisitedClipListReactor(clips: clips)
                    let vc = UnvisitedClipListViewController(reactor: reactor, diContainer: diContainer)
                    navigationController?.pushViewController(vc, animated: true)
                }
            }
            .disposed(by: disposeBag)
    }
}
