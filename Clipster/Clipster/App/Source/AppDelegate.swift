import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?,
    ) -> Bool {
        CoreDataStack.shared.migrateIfNeeded()
        CoreDataStack.shared.container
            .loadPersistentStores { _, error in
                if let error {
                    fatalError("\(Self.self): ❌ Failed to load persistent stores: \(error.localizedDescription)")
                } else {
                    print("\(Self.self): ✅ Persistent store loaded successfully")
                }
            }

        return true
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions,
    ) -> UISceneConfiguration {
        UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role,
        )
    }
}
