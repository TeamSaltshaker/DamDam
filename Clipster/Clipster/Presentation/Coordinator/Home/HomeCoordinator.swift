import SafariServices
import UIKit

final class HomeCoordinator: Coordinator {
    private let diContainer: DIContainer

    let navigationController: UINavigationController
    var parent: Coordinator?
    var childs: [Coordinator] = []

    init(navigationController: UINavigationController, diContainer: DIContainer) {
        self.navigationController = navigationController
        self.diContainer = diContainer
    }

    func start() {
        showHome()
    }
}

extension HomeCoordinator {
    func showHome() {
        let reactor = diContainer.makeHomeReactor()
        let vc = HomeViewController(reactor: reactor, coordinator: self)
        navigationController.pushViewController(vc, animated: true)
    }

    func showAddClip(folder: Folder?) {
        let reactor = diContainer.makeEditClipReactor(folder: folder)
        let vc = EditClipViewController(reactor: reactor, coordinator: self)
        navigationController.pushViewController(vc, animated: true)
    }

    func showDetailClip(clip: Clip) {
        let reactor = diContainer.makeClipDetailReactor(clip: clip)
        let vc = ClipDetailViewController(reactor: reactor, coordinator: self)
        navigationController.pushViewController(vc, animated: true)
    }

    func showUnvisitedClipList(clips: [Clip]) {
        let reactor = diContainer.makeUnvisitedClipListReactor(clips: clips)
        let vc = UnvisitedClipListViewController(reactor: reactor, coordinator: self)
        navigationController.pushViewController(vc, animated: true)
    }

    func showEditClip(clip: Clip) {
        let reactor = diContainer.makeEditClipReactor(clip: clip)
        let vc = EditClipViewController(reactor: reactor, coordinator: self)
        navigationController.pushViewController(vc, animated: true)
    }

    func showAddFolder(
        parentFolder: Folder? = nil,
    ) {
        let reactor = diContainer.makeEditFolderReactor(parentFolder: parentFolder, folder: nil)
        let vc = EditFolderViewController(reactor: reactor, coordinator: self)
        navigationController.pushViewController(vc, animated: true)
    }

    func showFolder(folder: Folder) {
        let reactor = diContainer.makeFolderReactor(folder: folder)
        let vc = FolderViewController(reactor: reactor, coordinator: self)
        navigationController.pushViewController(vc, animated: true)
    }

    func showEditFolder(parentFolder: Folder? = nil, folder: Folder? = nil) {
        let reactor = self.diContainer.makeEditFolderReactor(parentFolder: parentFolder, folder: folder)
        let vc = EditFolderViewController(reactor: reactor, coordinator: self)
        navigationController.pushViewController(vc, animated: true)
    }

    func showWebView(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        navigationController.present(safariVC, animated: true)
    }
}
