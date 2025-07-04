import CoreData

@objc(Folder)
public class FolderEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var depth: Int16
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var deletedAt: Date?

    @NSManaged public var parentFolder: FolderEntity?
    @NSManaged public var folders: Set<FolderEntity>?
    @NSManaged public var clips: Set<ClipEntity>?
}

extension FolderEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FolderEntity> {
        NSFetchRequest<FolderEntity>(entityName: "Folder")
    }
}
