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
    var userDefaults: UserDefaults = .standard

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        if let userDefaults = UserDefaults(suiteName: appGroupID) {
            self.userDefaults = userDefaults
        } else {
            print("❌ Failed to initialize App Group UserDefaults, using .standard instead.")
        }

        let navigationController = UINavigationController()
        navigationController.isNavigationBarHidden = true

        let supabaseURLString = Bundle.main.infoDictionary?["SUPABASE_URL"] as? String ?? ""
        let supabaseKey = Bundle.main.infoDictionary?["SUPABASE_KEY"] as? String ?? ""
        let cache = FolderClipCache()

        if let supabaseURL = URL(string: supabaseURLString) {
            let diContainer = DIContainer(
                supabaseURL: supabaseURL,
                supabaseKey: supabaseKey,
                cache: cache,
                userDefaults: userDefaults
            )

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
}
