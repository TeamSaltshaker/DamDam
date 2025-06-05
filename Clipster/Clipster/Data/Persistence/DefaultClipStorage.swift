import CoreData

final class DefaultClipStorage: ClipStorage {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func insertClip(_ clip: Clip) -> Result<Void, CoreDataError> {
        let entity = ClipEntity(context: context)

        entity.id = clip.id
        entity.memo = clip.memo
        entity.lastVisitedAt = clip.lastVisitedAt
        entity.createdAt = clip.createdAt
        entity.updatedAt = clip.updatedAt

        guard let folderEntity = fetchFolderEntity(by: clip.folderID) else {
            print("\(Self.self): ❌ Failed to insert: Entity not found")
            return .failure(.entityNotFound)
        }
        entity.folder = folderEntity

        let urlMetadataEntity = makeURLMetadataEntity(clip.urlMetadata)
        urlMetadataEntity.clip = entity
        entity.urlMetadata = urlMetadataEntity

        do {
            try context.save()
            print("\(Self.self): ✅ Insert successfully")
            return .success(())
        } catch {
            print("\(Self.self): ❌ Failed to insert: \(error.localizedDescription)")
            return .failure(.insertFailed(error.localizedDescription))
        }
    }

    private func fetchFolderEntity(by id: UUID) -> FolderEntity? {
        let request = FolderEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1

        return try? context.fetch(request).first
    }

    private func makeURLMetadataEntity(_ urlMetadata: URLMetadata) -> URLMetadataEntity {
        let entity = URLMetadataEntity(context: context)
        entity.urlString = urlMetadata.url.absoluteString
        entity.title = urlMetadata.title
        entity.thumbnailImageURLString = urlMetadata.thumbnailImageURL.absoluteString
        entity.createdAt = urlMetadata.createdAt
        entity.updatedAt = urlMetadata.updatedAt

        return entity
    }
}
