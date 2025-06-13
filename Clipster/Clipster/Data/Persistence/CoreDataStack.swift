import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()

    private let appGroupID: String = {
        #if DEBUG
        return "group.com.saltshaker.clipster.debug"
        #else
        return "group.com.saltshaker.clipster"
        #endif
    }()

    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Clipster")

        if let appGroupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID,
        ) {
            let storeURL = appGroupURL.appendingPathComponent("Clipster.sqlite")
            let description = NSPersistentStoreDescription(url: storeURL)
            container.persistentStoreDescriptions = [description]
        } else {
            fatalError("\(Self.self): ❌ Failed to locate AppGroup container")
        }

        container.loadPersistentStores { _, error in
            if let error {
                fatalError("\(Self.self): ❌ Failed to load persistent stores: \(error.localizedDescription)")
            } else {
                print("\(Self.self): ✅ Persistent store loaded successfully")
            }
        }
        return container
    }()

    private init() {}
}
