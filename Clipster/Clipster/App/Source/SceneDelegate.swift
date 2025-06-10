import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions,
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let diContainer = DIContainer()
        let homeVM = diContainer.makeHomeViewModel()
        let homeVC = HomeViewController(homeviewModel: homeVM, diContainer: diContainer)

        window = UIWindow(windowScene: windowScene)
        window?.backgroundColor = .systemBackground
        window?.rootViewController = UINavigationController(rootViewController: homeVC)
        window?.makeKeyAndVisible()
    }
}
