import RxCocoa
import RxSwift
import SafariServices
import UIKit

final class HomeViewController: UIViewController {
    private let disposeBag = DisposeBag()

    private let homeviewModel: HomeViewModel
    private let diContainer: DIContainer
    private let homeView = HomeView()

    init(homeviewModel: HomeViewModel, diContainer: DIContainer) {
        self.homeviewModel = homeviewModel
        self.diContainer = diContainer
        super.init(nibName: nil, bundle: nil)
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
        homeviewModel.action.accept(.viewWillAppear)
    }
}

private extension HomeViewController {
    func configure() {
        setAttributes()
        setBindings()
    }

    func setAttributes() {
        title = "Clipster"
        navigationController?.isNavigationBarHidden = true
    }

    func setBindings() {
        homeView.action
            .bind(with: self) { owner, action in
                switch action {
                case .tapAddFolder:
                    owner.homeviewModel.action.accept(.tapAddFolder)
                case .tapAddClip:
                    owner.homeviewModel.action.accept(.tapAddClip)
                case .tapCell(let indexPath):
                    owner.homeviewModel.action.accept(.tapCell(indexPath))
                case .detail(let indexPath):
                    owner.homeviewModel.action.accept(.tapDetail(indexPath))
                case .edit(let indexPath):
                    owner.homeviewModel.action.accept(.tapEdit(indexPath))
                case .delete(let indexPath, let title):
                    owner.presentDeleteAlert(title: title) { [weak self] in
                        self?.homeviewModel.action.accept(.tapDelete(indexPath))
                    }
                case .showAllClips:
                    owner.homeviewModel.action.accept(.tapShowAllClips)
                }
            }
            .disposed(by: disposeBag)

        homeviewModel.state
            .asSignal()
            .emit(with: self) { owner, state in
                switch state {
                case .homeDisplay(let homeDisplay):
                    owner.homeView.setDisplay(homeDisplay)
                }
            }
            .disposed(by: disposeBag)

        homeviewModel.route
            .asSignal()
            .emit(with: self) { owner, route in
                switch route {
                case .showAddClip(let folder):
                    let vm = owner.diContainer.makeEditClipViewModel(folder: folder)
                    let vc = EditClipViewController(
                        viewModel: vm,
                        diContainer: owner.diContainer
                    )
                    owner.navigationController?.pushViewController(vc, animated: true)
                case .showAddFolder:
                    let vm = owner.diContainer.makeEditFolderViewModel(mode: .add(parentFolder: nil))
                    let vc = EditFolderViewController(
                        viewModel: vm,
                        diContainer: owner.diContainer
                    )
                    owner.navigationController?.pushViewController(vc, animated: true)
                case .showWebView(let url):
                    let vc = SFSafariViewController(url: url)
                    owner.present(vc, animated: true)
                case .showFolder(let folder):
                    let vm = owner.diContainer.makeFolderViewModel(folder: folder)
                    let vc = FolderViewController(
                        viewModel: vm,
                        diContainer: owner.diContainer
                    )
                    owner.navigationController?.pushViewController(vc, animated: true)
                case .showDetailClip(let clip):
                    let vm = owner.diContainer.makeClipDetailViewModel(clip: clip)
                    let vc = ClipDetailViewController(
                        viewModel: vm,
                        diContainer: owner.diContainer
                    )
                    owner.navigationController?.pushViewController(vc, animated: true)
                case .showEditClip(let clip):
                    let vm = owner.diContainer.makeEditClipViewModel(clip: clip)
                    let vc = EditClipViewController(
                        viewModel: vm,
                        diContainer: owner.diContainer
                    )
                    owner.navigationController?.pushViewController(vc, animated: true)
                case .showEditFolder(let folder):
                    let vm = owner.diContainer.makeEditFolderViewModel(
                        mode: .edit(parentFolder: nil, folder: folder)
                    )
                    let vc = EditFolderViewController(
                        viewModel: vm,
                        diContainer: owner.diContainer
                    )
                    owner.navigationController?.pushViewController(vc, animated: true)
                case .showUnvisitedClipList(let clips):
                    let vm = owner.diContainer.makeUnvisitedClipListViewModel(clips: clips)
                    let vc = UnvisitedClipListViewController(
                        unvisitedClipListViewModel: vm,
                        diContainer: owner.diContainer,
                    )
                    owner.navigationController?.pushViewController(vc, animated: true)
                }
            }
            .disposed(by: disposeBag)
    }
}
