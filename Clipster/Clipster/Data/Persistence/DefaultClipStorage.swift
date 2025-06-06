import CoreData

final class DefaultClipStorage: ClipStorage {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchClip(by id: UUID) -> Result<ClipEntity, CoreDataError> {
        let request = ClipEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@ AND deletedAt == nil", id as CVarArg)
        request.fetchLimit = 1

        do {
            guard let entity = try context.fetch(request).first else {
                print("\(Self.self): ❌ Failed to fetch: Entity not found")
                return .failure(.entityNotFound)
            }
            print("\(Self.self): ✅ Fetch successfully")
            return .success(entity)
        } catch {
            print("\(Self.self): ❌ Failed to fetch: \(error.localizedDescription)")
            return .failure(.fetchFailed(error.localizedDescription))
        }
    }

    func fetchUnvisitedClips() -> Result<[ClipEntity], CoreDataError> {
        let request = ClipEntity.fetchRequest()
        request.predicate = NSPredicate(format: "lastVisitedAt == nil AND deletedAt == nil")

        do {
            let entities = try context.fetch(request)
            print("\(Self.self): ✅ Fetch successfully")
            return .success(entities)
        } catch {
            print("\(Self.self): ❌ Failed to fetch: \(error.localizedDescription)")
            return .failure(.fetchFailed(error.localizedDescription))
        }
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
        request.predicate = NSPredicate(format: "id == %@ AND deletedAt == nil", id as CVarArg)
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

#if DEBUG
extension DefaultClipStorage {
    func fetchAllClipsForDebug() -> [ClipEntity]? {
        try? context.fetch(ClipEntity.fetchRequest())
    }
}
#endif
