import CoreData

final class DefaultClipStorage: ClipStorage {
    private let container: NSPersistentContainer
    private let mapper: DomainMapper

    init(container: NSPersistentContainer, mapper: DomainMapper) {
        self.container = container
        self.mapper = mapper
    }

    func fetchClip(by id: UUID) async -> Result<Clip, CoreDataError> {
        await withCheckedContinuation { [weak self] continuation in
            guard let self else { return }

            container.performBackgroundTask { context in
                let request = ClipEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@ AND deletedAt == nil", id as CVarArg)
                request.fetchLimit = 1

                do {
                    guard let entity = try context.fetch(request).first else {
                        print("\(Self.self): ❌ Failed to fetch: Entity not found")
                        continuation.resume(returning: .failure(.entityNotFound))
                        return
                    }
                    guard let clip = self.mapper.clip(from: entity) else {
                        print("\(Self.self): ❌ Failed to fetch: Mapping failed")
                        continuation.resume(returning: .failure(.mapFailed))
                        return
                    }
                    print("\(Self.self): ✅ Fetch successfully")
                    continuation.resume(returning: .success(clip))
                } catch {
                    print("\(Self.self): ❌ Failed to fetch: \(error.localizedDescription)")
                    continuation.resume(returning: .failure(.fetchFailed(error.localizedDescription)))
                }
            }
        }
    }

    func fetchUnvisitedClips() async -> Result<[Clip], CoreDataError> {
        await withCheckedContinuation { [weak self] continuation in
            guard let self else { return }

            container.performBackgroundTask { context in
                let request = ClipEntity.fetchRequest()
                request.predicate = NSPredicate(format: "lastVisitedAt == nil AND deletedAt == nil")

                do {
                    let entities = try context.fetch(request)
                    let unvisitedClips = entities.compactMap(self.mapper.clip)
                    print("\(Self.self): ✅ Fetch successfully")
                    continuation.resume(returning: .success(unvisitedClips))
                } catch {
                    print("\(Self.self): ❌ Failed to fetch: \(error.localizedDescription)")
                    continuation.resume(returning: .failure(.fetchFailed(error.localizedDescription)))
                }
            }
        }
    }

    func insertClip(_ clip: Clip) async -> Result<Void, CoreDataError> {
        await withCheckedContinuation { continuation in
            container.performBackgroundTask { context in
                let entity = ClipEntity(context: context)
                entity.id = clip.id
                entity.memo = clip.memo
                entity.lastVisitedAt = clip.lastVisitedAt
                entity.createdAt = clip.createdAt
                entity.updatedAt = clip.updatedAt

                let request = FolderEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@ AND deletedAt == nil", clip.folderID as CVarArg)
                request.fetchLimit = 1

                do {
                    guard let parentEntity = try context.fetch(request).first else {
                        print("\(Self.self): ❌ Failed to insert: Parent entity not found")
                        continuation.resume(returning: .failure(.entityNotFound))
                        return
                    }
                    entity.folder = parentEntity
                } catch {
                    print("\(Self.self): ❌ Failed to insert: \(error.localizedDescription)")
                    continuation.resume(returning: .failure(.insertFailed(error.localizedDescription)))
                }

                let urlMetadataEntity = URLMetadataEntity(context: context)
                urlMetadataEntity.urlString = clip.urlMetadata.url.absoluteString
                urlMetadataEntity.title = clip.urlMetadata.title
                urlMetadataEntity.thumbnailImageURLString = clip.urlMetadata.thumbnailImageURL?.absoluteString
                urlMetadataEntity.createdAt = clip.urlMetadata.createdAt
                urlMetadataEntity.updatedAt = clip.urlMetadata.updatedAt

                urlMetadataEntity.clip = entity
                entity.urlMetadata = urlMetadataEntity

                do {
                    try context.save()
                    print("\(Self.self): ✅ Insert successfully")
                    continuation.resume(returning: .success(()))
                } catch {
                    print("\(Self.self): ❌ Failed to insert: \(error.localizedDescription)")
                    continuation.resume(returning: .failure(.insertFailed(error.localizedDescription)))
                }
            }
        }
    }

    func updateClip(_ clip: Clip) async -> Result<Void, CoreDataError> {
        await withCheckedContinuation { continuation in
            container.performBackgroundTask { context in
                let request = ClipEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@ AND deletedAt == nil", clip.id as CVarArg)
                request.fetchLimit = 1

                do {
                    guard let entity = try context.fetch(request).first else {
                        print("\(Self.self): ❌ Failed to update: Entity not found")
                        continuation.resume(returning: .failure(.entityNotFound))
                        return
                    }

                    entity.memo = clip.memo
                    entity.lastVisitedAt = clip.lastVisitedAt
                    entity.updatedAt = clip.updatedAt

                    if entity.folder?.id != clip.folderID {
                        let request = FolderEntity.fetchRequest()
                        request.predicate = NSPredicate(
                            format: "id == %@ AND deletedAt == nil",
                            clip.folderID as CVarArg,
                        )
                        request.fetchLimit = 1

                        guard let folderEntity = try context.fetch(request).first else {
                            print("\(Self.self): ❌ Failed to update: Parent entity not found")
                            continuation.resume(returning: .failure(.entityNotFound))
                            return
                        }
                        entity.folder = folderEntity
                    }

                    entity.urlMetadata?.urlString = clip.urlMetadata.url.absoluteString
                    entity.urlMetadata?.title = clip.urlMetadata.title
                    entity.urlMetadata?.thumbnailImageURLString = clip.urlMetadata.thumbnailImageURL?.absoluteString
                    entity.urlMetadata?.updatedAt = clip.urlMetadata.updatedAt

                    try context.save()
                    print("\(Self.self): ✅ Update successfully")
                    continuation.resume(returning: .success(()))
                } catch {
                    print("\(Self.self): ❌ Failed to update: \(error.localizedDescription)")
                    continuation.resume(returning: .failure(.updateFailed(error.localizedDescription)))
                }
            }
        }
    }

    func deleteClip(_ clip: Clip) async -> Result<Void, CoreDataError> {
        await withCheckedContinuation { continuation in
            container.performBackgroundTask { context in
                let request = ClipEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@ AND deletedAt == nil", clip.id as CVarArg)
                request.fetchLimit = 1

                do {
                    guard let entity = try context.fetch(request).first else {
                        print("\(Self.self): ❌ Failed to delete: Entity not found")
                        continuation.resume(returning: .failure(.entityNotFound))
                        return
                    }

                    entity.deletedAt = clip.deletedAt
                    entity.urlMetadata?.deletedAt = clip.urlMetadata.deletedAt

                    try context.save()
                    print("\(Self.self): ✅ Delete successfully")
                    continuation.resume(returning: .success(()))
                } catch {
                    print("\(Self.self): ❌ Failed to delete: \(error.localizedDescription)")
                    continuation.resume(returning: .failure(.updateFailed(error.localizedDescription)))
                }
            }
        }
    }
}
