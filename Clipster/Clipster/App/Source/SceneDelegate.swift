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

        #if DEBUG
        _ = UserDefaults(suiteName: "group.com.saltshaker.clipster.debug")
        #else
        _ = UserDefaults(suiteName: "group.com.saltshaker.clipster")
        #endif

        let navigationController = UINavigationController()
        navigationController.isNavigationBarHidden = true

        let supabaseURLString = Bundle.main.infoDictionary?["SUPABASE_URL"] as? String ?? ""
        let supabaseKey = Bundle.main.infoDictionary?["SUPABASE_KEY"] as? String ?? ""

        if let supabaseURL = URL(string: supabaseURLString) {
            let diContainer = DIContainer(supabaseURL: supabaseURL, supabaseKey: supabaseKey)

            appCoordinator = AppCoordinator(
                navigationController: navigationController,
                diContainer: diContainer
            )

            window = UIWindow(windowScene: windowScene)
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()

            appCoordinator?.start()
        } else {
            print("\(Self.self): ❌ Invalid Supabase URL")
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        if let sharedDefaults = UserDefaults(suiteName: appGroupID),
           let urlString = sharedDefaults.string(forKey: "sharedURL") {
            sharedDefaults.removeObject(forKey: "sharedURL")

            DispatchQueue.main.async {
                self.appCoordinator?.handleSharedURL(urlString)
            }
        }
    }
}
