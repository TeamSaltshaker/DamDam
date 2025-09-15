import CoreData

final class DefaultClipStorage: ClipStorage {
    private let container: NSPersistentContainer
    private let mapper: DomainMapper

    init(container: NSPersistentContainer, mapper: DomainMapper) {
        self.container = container
        self.mapper = mapper
    }

    func fetchClip(
        predicate: NSPredicate,
    ) async -> Result<Clip, CoreDataError> {
        let result = await fetchClips(predicate: predicate, fetchLimit: 1)

        switch result {
        case .success(let clips):
            if let clip = clips.first {
                return .success(clip)
            } else {
                return .failure(.entityNotFound)
            }
        case .failure(let error):
            return .failure(error)
        }
    }

    func fetchClips(
        predicate: NSPredicate,
        fetchLimit: Int,
    ) async -> Result<[Clip], CoreDataError> {
        await withCheckedContinuation { continuation in
            container.performBackgroundTask { [weak self] context in
                guard let self else { return }

                let request = ClipEntity.fetchRequest()
                request.predicate = predicate
                request.fetchLimit = fetchLimit

                do {
                    let entities = try context.fetch(request)
                    let clips = entities.compactMap(mapper.clip)
                    print("\(Self.self): ✅ Fetch successfully")
                    continuation.resume(returning: .success(clips))
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

                if let folderID = clip.folderID {
                    let request = FolderEntity.fetchRequest()
                    request.predicate = NSPredicate(
                        format: "id == %@ AND deletedAt == nil",
                        folderID as CVarArg,
                    )
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
                }

                let urlMetadataEntity = URLMetadataEntity(context: context)
                urlMetadataEntity.urlString = clip.url.absoluteString
                urlMetadataEntity.title = clip.title
                urlMetadataEntity.subtitle = clip.subtitle
                urlMetadataEntity.thumbnailImageURLString = clip.thumbnailImageURL?.absoluteString
                urlMetadataEntity.screenshotData = clip.screenshotData
                urlMetadataEntity.createdAt = clip.createdAt
                urlMetadataEntity.updatedAt = clip.updatedAt

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
                        if let folderID = clip.folderID {
                            let request = FolderEntity.fetchRequest()
                            request.predicate = NSPredicate(
                                format: "id == %@ AND deletedAt == nil",
                                folderID as CVarArg,
                            )
                            request.fetchLimit = 1

                            guard let folderEntity = try context.fetch(request).first else {
                                print("\(Self.self): ❌ Failed to update: Parent entity not found")
                                continuation.resume(returning: .failure(.entityNotFound))
                                return
                            }
                            entity.folder = folderEntity
                        } else {
                            entity.folder = nil
                        }
                    }

                    entity.urlMetadata?.urlString = clip.url.absoluteString
                    entity.urlMetadata?.title = clip.title
                    entity.urlMetadata?.subtitle = clip.subtitle
                    entity.urlMetadata?.thumbnailImageURLString = clip.thumbnailImageURL?.absoluteString
                    entity.urlMetadata?.screenshotData = clip.screenshotData
                    entity.urlMetadata?.updatedAt = clip.updatedAt

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
                    entity.urlMetadata?.deletedAt = clip.deletedAt

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
