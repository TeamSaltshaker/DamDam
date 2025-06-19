import CoreData

final class ClipToClipMigrationPolicy: NSEntityMigrationPolicy {
    override func createDestinationInstances(
        forSource sInstance: NSManagedObject,
        in mapping: NSEntityMapping,
        manager: NSMigrationManager
    ) throws {
        try super.createDestinationInstances(forSource: sInstance, in: mapping, manager: manager)

        guard let dInstance = manager.destinationInstances(
            forEntityMappingName: mapping.name,
            sourceInstances: [sInstance]
        ).first else {
            return
        }

        ["id", "memo", "lastVisitedAt", "createdAt", "updatedAt", "deletedAt"].forEach {
            if let attribute = sInstance.value(forKey: $0) {
                dInstance.setValue(attribute, forKey: $0)
            }
        }

        if let sourceURLMetadata = sInstance.value(forKey: "urlMetadata") as? NSManagedObject {
            ["title", "urlString", "thumbnailImageURLString"].forEach {
                if let attribute = sourceURLMetadata.value(forKey: $0) {
                    dInstance.setValue(attribute, forKey: $0)
                }
            }
        }

        dInstance.setValue(nil, forKey: "screenshotData")
    }
}
