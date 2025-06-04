import CoreData

@objc(Folder)
public class FolderEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var deletedAt: Date?

    @NSManaged public var parentFolder: FolderEntity?
    @NSManaged public var folders: Set<FolderEntity>?
    @NSManaged public var clips: Set<ClipEntity>?
}
