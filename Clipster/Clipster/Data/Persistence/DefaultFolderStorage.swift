import CoreData

final class DefaultFolderStorage: FolderStorage {
    private let container: NSPersistentContainer
    private let mapper: DomainMapper

    init(container: NSPersistentContainer, mapper: DomainMapper) {
        self.container = container
        self.mapper = mapper
    }

    func fetchFolder(by id: UUID) async -> Result<Folder, CoreDataError> {
        await withCheckedContinuation { [weak self] continuation in
            guard let self else { return }

            container.performBackgroundTask { context in
                let request = FolderEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@ AND deletedAt == nil", id as CVarArg)
                request.fetchLimit = 1

                do {
                    guard let entity = try context.fetch(request).first else {
                        print("\(Self.self): ❌ Failed to fetch: Entity not found")
                        continuation.resume(returning: .failure(.entityNotFound))
                        return
                    }
                    entity.folders = entity.folders?.filter { $0.deletedAt == nil }
                    entity.clips = entity.clips?.filter { $0.deletedAt == nil }

                    guard let folder = self.mapper.folder(from: entity) else {
                        print("\(Self.self): ❌ Failed to fetch: Mapping failed")
                        continuation.resume(returning: .failure(.mapFailed))
                        return
                    }
                    print("\(Self.self): ✅ Fetch successfully")
                    continuation.resume(returning: .success(folder))
                } catch {
                    print("\(Self.self): ❌ Failed to fetch: \(error.localizedDescription)")
                    continuation.resume(returning: .failure(.fetchFailed(error.localizedDescription)))
                }
            }
        }
    }

    func fetchAllFolders() async -> Result<[Folder], CoreDataError> {
        await withCheckedContinuation { [weak self] continuation in
            guard let self else { return }

            container.performBackgroundTask { context in
                let request = FolderEntity.fetchRequest()
                request.predicate = NSPredicate(format: "deletedAt == nil")

                do {
                    let entities = try context.fetch(request)
                    for entity in entities {
                        entity.folders = entity.folders?.filter { $0.deletedAt == nil }
                        entity.clips = entity.clips?.filter { $0.deletedAt == nil }
                    }

                    let allFolders = entities.compactMap(self.mapper.folder)
                    print("\(Self.self): ✅ Fetch successfully")
                    continuation.resume(returning: .success(allFolders))
                } catch {
                    print("\(Self.self): ❌ Failed to fetch: \(error.localizedDescription)")
                    continuation.resume(returning: .failure(.fetchFailed(error.localizedDescription)))
                }
            }
        }
    }

    func fetchTopLevelFolders() async -> Result<[Folder], CoreDataError> {
        await withCheckedContinuation { [weak self] continuation in
            guard let self else { return }

            container.performBackgroundTask { context in
                let request = FolderEntity.fetchRequest()
                request.predicate = NSPredicate(format: "parentFolder == nil AND deletedAt == nil")

                do {
                    let entities = try context.fetch(request)
                    for entity in entities {
                        entity.folders = entity.folders?.filter { $0.deletedAt == nil }
                        entity.clips = entity.clips?.filter { $0.deletedAt == nil }
                    }

                    let topLevelFolders = entities.compactMap(self.mapper.folder)
                    print("\(Self.self): ✅ Fetch successfully")
                    continuation.resume(returning: .success(topLevelFolders))
                } catch {
                    print("\(Self.self): ❌ Failed to fetch: \(error.localizedDescription)")
                    continuation.resume(returning: .failure(.fetchFailed(error.localizedDescription)))
                }
            }
        }
    }

    func insertFolder(_ folder: Folder) async -> Result<Void, CoreDataError> {
        await withCheckedContinuation { continuation in
            container.performBackgroundTask { context in
                let entity = FolderEntity(context: context)

                entity.id = folder.id
                entity.title = folder.title
                entity.depth = Int16(folder.depth)
                entity.createdAt = folder.createdAt
                entity.updatedAt = folder.updatedAt

                if let parentFolderID = folder.parentFolderID {
                    let request = FolderEntity.fetchRequest()
                    request.predicate = NSPredicate(
                        format: "id == %@ AND deletedAt == nil",
                        parentFolderID as CVarArg,
                    )
                    request.fetchLimit = 1

                    do {
                        guard let parentEntity = try context.fetch(request).first else {
                            print("\(Self.self): ❌ Failed to insert: Parent entity not found")
                            continuation.resume(returning: .failure(.entityNotFound))
                            return
                        }
                        entity.parentFolder = parentEntity
                    } catch {
                        print("\(Self.self): ❌ Failed to insert: \(error.localizedDescription)")
                        continuation.resume(returning: .failure(.insertFailed(error.localizedDescription)))
                    }
                }

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

    func updateFolder(_ folder: Folder) async -> Result<Void, CoreDataError> {
        await withCheckedContinuation { continuation in
            container.performBackgroundTask { context in
                let request = FolderEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@ AND deletedAt == nil", folder.id as CVarArg)
                request.fetchLimit = 1

                do {
                    guard let entity = try context.fetch(request).first else {
                        print("\(Self.self): ❌ Failed to update: Entity not found")
                        continuation.resume(returning: .failure(.entityNotFound))
                        return
                    }

                    entity.title = folder.title
                    entity.depth = Int16(folder.depth)
                    entity.updatedAt = folder.updatedAt

                    if entity.parentFolder?.id != folder.parentFolderID {
                        if let parentFolderID = folder.parentFolderID {
                            let request = FolderEntity.fetchRequest()
                            request.predicate = NSPredicate(
                                format: "id == %@ AND deletedAt == nil",
                                parentFolderID as CVarArg,
                            )
                            request.fetchLimit = 1

                            guard let parentEntity = try context.fetch(request).first else {
                                print("\(Self.self): ❌ Failed to update: Parent entity not found")
                                continuation.resume(returning: .failure(.entityNotFound))
                                return
                            }
                            entity.parentFolder = parentEntity
                        }
                    }

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

    func deleteFolder(_ folder: Folder) async -> Result<Void, CoreDataError> {
        await withCheckedContinuation { [weak self] continuation in
            guard let self else { return }

            container.performBackgroundTask { context in
                let request = FolderEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@ AND deletedAt == nil", folder.id as CVarArg)
                request.fetchLimit = 1

                do {
                    guard let entity = try context.fetch(request).first else {
                        print("\(Self.self): ❌ Failed to delete: Entity not found")
                        continuation.resume(returning: .failure(.entityNotFound))
                        return
                    }

                    self.deleteFolder(entity, deletedAt: folder.deletedAt)

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

    private func deleteFolder(_ entity: FolderEntity, deletedAt: Date?) {
        entity.deletedAt = deletedAt

        entity.folders?
            .filter { $0.deletedAt == nil }
            .forEach { subEntity in
                deleteFolder(subEntity, deletedAt: deletedAt)
            }

        entity.clips?
            .filter { $0.deletedAt == nil }
            .forEach { subEntity in
                subEntity.deletedAt = deletedAt
                subEntity.urlMetadata?.deletedAt = deletedAt
            }
    }
}
