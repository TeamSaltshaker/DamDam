import CoreData

@objc(URLMetadata)
public class URLMetadataEntity: NSManagedObject {
    @NSManaged public var urlString: String
    @NSManaged public var title: String
    @NSManaged public var body: String
    @NSManaged public var thumbnailImageURLString: String
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var deletedAt: Date?

    @NSManaged public var clip: ClipEntity?
}
