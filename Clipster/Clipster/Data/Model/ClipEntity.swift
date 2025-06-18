import CoreData

@objc(Clip)
public class ClipEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var urlString: String
    @NSManaged public var title: String
    @NSManaged public var memo: String
    @NSManaged public var thumbnailImageURLString: String?
    @NSManaged public var screenshotData: Data?
    @NSManaged public var lastVisitedAt: Date?
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var deletedAt: Date?

    @NSManaged public var folder: FolderEntity?
}

extension ClipEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ClipEntity> {
        NSFetchRequest<ClipEntity>(entityName: "Clip")
    }
}
