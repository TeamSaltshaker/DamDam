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
        let fetchUnvisitedClipsUseCase = DefaultFetchUnvisitedClipsUseCase()
        let fetchTopLevelFoldersUseCase = DefaultFetchTopLevelFoldersUseCase()
        let deleteClipUseCase = DefaultDeleteClipUseCase()
        let deleteFolderUseCase = DefaultDeleteFolderUseCase()
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
