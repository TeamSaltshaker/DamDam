import CoreData

@objc(Clip)
public class ClipEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var memo: String
    @NSManaged public var lastVisitedAt: Date?
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var deletedAt: Date?

    @NSManaged public var folder: FolderEntity?
    @NSManaged public var urlMetadata: URLMetadataEntity?
}

extension ClipEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ClipEntity> {
        NSFetchRequest<ClipEntity>(entityName: "Clip")
    }
}
