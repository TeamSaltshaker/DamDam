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

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions,
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let diContainer = DIContainer()
        let reactor = diContainer.makeHomeReactor()
        let homeVC = HomeViewController(reactor: reactor, diContainer: diContainer)

        window = UIWindow(windowScene: windowScene)
        window?.backgroundColor = .white800
        window?.rootViewController = UINavigationController(rootViewController: homeVC)
        window?.makeKeyAndVisible()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        if let sharedDefaults = UserDefaults(suiteName: appGroupID),
           let urlString = sharedDefaults.string(forKey: "sharedURL") {
            sharedDefaults.removeObject(forKey: "sharedURL")

            DispatchQueue.main.async {
                if let rootVC = self.window?.rootViewController as? UINavigationController {
                    let diContainer = DIContainer()
                    let editVM = diContainer.makeEditClipViewModel(urlString: urlString)
                    let editClipVC = EditClipViewController(viewModel: editVM, diContainer: diContainer)
                    rootVC.pushViewController(editClipVC, animated: true)
                }
            }
        }
    }
}
