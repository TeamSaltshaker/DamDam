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

    func migrateIfNeeded() {
        let migrationKey = "hasMigratedToClipster2Model"

        guard let userDefaults = UserDefaults(suiteName: appGroupID) else {
            print("\(Self.self): ❌ Failed to access App Group UserDefaults")
            return
        }

        guard !userDefaults.bool(forKey: migrationKey) else {
            print("\(Self.self): ✅ Migration already completed, skipping")
            return
        }

        guard let appGroupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        ) else {
            fatalError("\(Self.self): ❌ App Group container URL not found")
        }

        let storeURL = appGroupURL.appendingPathComponent("Clipster.sqlite")

        guard let sourceModelURL = Bundle.main.url(forResource: "Clipster", withExtension: "momd"),
              let sourceModel = NSManagedObjectModel(contentsOf: sourceModelURL) else {
            print("\(Self.self): ❌ Failed to load source model")
            return
         }

        guard let destinationModelURL = Bundle.main.url(forResource: "Clipster2", withExtension: "momd"),
              let destinationModel = NSManagedObjectModel(contentsOf: destinationModelURL) else {
            print("\(Self.self): ❌ Failed to load destination model")
            return
        }

        guard let mappingModelURL = Bundle.main.url(forResource: "ClipsterToClipster2", withExtension: "cdm"),
              let mappingModel = NSMappingModel(contentsOf: mappingModelURL) else {
            print("\(Self.self): ❌ Failed to load mapping model")
            return
        }

        let tempURL = storeURL.deletingLastPathComponent().appendingPathComponent("Temp.sqlite")
        let manager = NSMigrationManager(sourceModel: sourceModel, destinationModel: destinationModel)

        do {
            try manager.migrateStore(
                from: storeURL,
                sourceType: NSSQLiteStoreType,
                options: nil,
                with: mappingModel,
                toDestinationURL: tempURL,
                destinationType: NSSQLiteStoreType,
                destinationOptions: nil,
            )

            try FileManager.default.removeItem(at: storeURL)
            try FileManager.default.moveItem(at: tempURL, to: storeURL)

            userDefaults.set(true, forKey: migrationKey)
            print("\(Self.self): ✅ Migration completed successfully")
        } catch {
            print("\(Self.self): ❌ Migration failed: \(error.localizedDescription)")
        }
    }
}
