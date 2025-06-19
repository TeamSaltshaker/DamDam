import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    private let appGroupID: String = {
        #if DEBUG
        return "group.com.saltshaker.clipster.debug"
        #else
        return "group.com.saltshaker.clipster"
        #endif
    }()

    var window: UIWindow?
    var appCoordinator: AppCoordinator?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let navigationController = UINavigationController()
        let diContainer = DIContainer()

        appCoordinator = AppCoordinator(
            navigationController: navigationController,
            diContainer: diContainer
        )

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        appCoordinator?.start()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        if let sharedDefaults = UserDefaults(suiteName: appGroupID),
           let urlString = sharedDefaults.string(forKey: "sharedURL") {
            sharedDefaults.removeObject(forKey: "sharedURL")

            DispatchQueue.main.async {
                if let rootVC = self.window?.rootViewController as? UINavigationController {
                    let diContainer = DIContainer()
                    let reactor = diContainer.makeEditClipReactor(urlString: urlString)
                    let editClipVC = EditClipViewController(reactor: reactor, diContainer: diContainer)
                    rootVC.pushViewController(editClipVC, animated: true)
                }
            }
        }
    }
}
