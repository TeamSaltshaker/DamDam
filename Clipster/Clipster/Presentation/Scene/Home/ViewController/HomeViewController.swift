import ReactorKit
import RxCocoa
import RxSwift
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

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reactor?.action.onNext(.viewWillAppear)
    }

    func bind(reactor: HomeReactor) {
        bindAction(to: reactor)
        bindState(from: reactor)
        bindRoute(from: reactor)
    }
}

private extension HomeViewController {
    func bindAction(to reactor: HomeReactor) {
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

    func bindState(from reactor: HomeReactor) {
        reactor.state
            .compactMap { $0.homeDisplay }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] display in
                self?.homeView.setDisplay(display)
            }
            .disposed(by: disposeBag)
    }

    func bindRoute(from reactor: HomeReactor) {
        reactor.pulse(\.$route)
            .compactMap { $0 }
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .bind { [weak self] route in
                guard let self else { return }

                switch route {
                case .showAddClip(let folder):
                    let vm = diContainer.makeEditClipViewModel(folder: folder)
                    let vc = EditClipViewController(viewModel: vm, diContainer: diContainer)
                    navigationController?.pushViewController(vc, animated: true)
                case .showAddFolder:
                    let vm = diContainer.makeEditFolderViewModel(mode: .add(parentFolder: nil))
                    let vc = EditFolderViewController(viewModel: vm, diContainer: diContainer)
                    navigationController?.pushViewController(vc, animated: true)
                case .showWebView(let url):
                    let vc = SFSafariViewController(url: url)
                    present(vc, animated: true)
                case .showFolder(let folder):
                    let vm = diContainer.makeFolderViewModel(folder: folder)
                    let vc = FolderViewController(viewModel: vm, diContainer: diContainer)
                    navigationController?.pushViewController(vc, animated: true)
                case .showDetailClip(let clip):
                    let vm = diContainer.makeClipDetailViewModel(clip: clip)
                    let vc = ClipDetailViewController(viewModel: vm, diContainer: diContainer)
                    navigationController?.pushViewController(vc, animated: true)
                case .showEditClip(let clip):
                    let vm = diContainer.makeEditClipViewModel(clip: clip)
                    let vc = EditClipViewController(viewModel: vm, diContainer: diContainer)
                    navigationController?.pushViewController(vc, animated: true)
                case .showEditFolder(let folder):
                    let vm = diContainer.makeEditFolderViewModel(mode: .edit(parentFolder: nil, folder: folder))
                    let vc = EditFolderViewController(viewModel: vm, diContainer: diContainer)
                    navigationController?.pushViewController(vc, animated: true)
                case .showUnvisitedClipList(let clips):
                    let vm = diContainer.makeUnvisitedClipListViewModel(clips: clips)
                    let vc = UnvisitedClipListViewController(
                        unvisitedClipListViewModel: vm,
                        diContainer: diContainer
                    )
                    navigationController?.pushViewController(vc, animated: true)
                }
            }
            .disposed(by: disposeBag)
    }
}

private extension HomeViewController {
    func configure() {
        setAttributes()
    }

    func setAttributes() {
        navigationController?.isNavigationBarHidden = true
    }
}
