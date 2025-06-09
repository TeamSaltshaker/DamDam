import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions,
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let context = CoreDataStack.shared.context

        let clipStorage = DefaultClipStorage(context: context)
        let folderStorage = DefaultFolderStorage(context: context)

        let clipRepository = DefaultClipRepository(storage: clipStorage, mapper: DomainMapper())
        let folderRepository = DefaultFolderRepository(storage: folderStorage, mapper: DomainMapper())

        let fetchUnvisitedClipsUseCase = DefaultFetchUnvisitedClipsUseCase(clipRepository: clipRepository)
        let fetchTopLevelFoldersUseCase = DefaultFetchTopLevelFoldersUseCase(folderRepository: folderRepository)
        let deleteClipUseCase = DefaultDeleteClipUseCase(clipRepository: clipRepository)
        let deleteFolderUseCase = DefaultDeleteFolderUseCase(folderRepository: folderRepository)

        let homeViewModel = HomeViewModel(
            fetchUnvisitedClipsUseCase: fetchUnvisitedClipsUseCase,
            fetchTopLevelFoldersUseCase: fetchTopLevelFoldersUseCase,
            deleteClipUseCase: deleteClipUseCase,
            deleteFolderUseCase: deleteFolderUseCase
        )

        let homeVC = HomeViewController(homeviewModel: homeViewModel)
        window?.rootViewController = UINavigationController(rootViewController: homeVC)
        window?.makeKeyAndVisible()

        window?.backgroundColor = .systemBackground
    }
}
