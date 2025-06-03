import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()

    private let appGroupID = "group.com.saltshaker.clipster"

    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Clipster")

        if let appGroupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID,
        ) {
            let storeURL = appGroupURL.appendingPathComponent("Clipster.sqlite")
            let description = NSPersistentStoreDescription(url: storeURL)
            container.persistentStoreDescriptions = [description]
        } else {
            fatalError("❌ Failed to locate AppGroup container")
        }

        container.loadPersistentStores { description, error in
            if let error {
                fatalError("❌ Failed to load persistent stores: \(error.localizedDescription)")
            } else {
                print("✅ Persistent store loaded successfully")
                print("  - Store URL: \(description.url?.absoluteString ?? "")")
            }
        }
        return container
    }()

    private init() {}
}
