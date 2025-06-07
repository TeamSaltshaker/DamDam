import CoreData

final class DefaultFolderStorage: FolderStorage {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchFolder(by id: UUID) -> Result<FolderEntity, CoreDataError> {
        let request = FolderEntity.fetchRequest()
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

    func fetchTopLevelFolders() -> Result<[FolderEntity], CoreDataError> {
        let request = FolderEntity.fetchRequest()
        request.predicate = NSPredicate(format: "parentFolder == nil AND deletedAt == nil")

        do {
            let entities = try context.fetch(request)
            print("\(Self.self): ✅ Fetch successfully")
            return .success(entities)
        } catch {
            print("\(Self.self): ❌ Failed to fetch: \(error.localizedDescription)")
            return .failure(.fetchFailed(error.localizedDescription))
        }
    }

    func insertFolder(_ folder: Folder) -> Result<Void, CoreDataError> {
        let entity = FolderEntity(context: context)

        entity.id = folder.id
        entity.title = folder.title
        entity.depth = Int16(folder.depth)
        entity.createdAt = folder.createdAt
        entity.updatedAt = folder.updatedAt

        if let parentFolderID = folder.parentFolderID {
            let result = fetchFolder(by: parentFolderID)
            switch result {
            case .success(let parentEntity):
                entity.parentFolder = parentEntity
            case .failure(let error):
                print("\(Self.self): ❌ Failed to insert: \(error.localizedDescription)")
                return .failure(.insertFailed(error.localizedDescription))
            }
        }

        do {
            try context.save()
            print("\(Self.self): ✅ Insert successfully")
            return .success(())
        } catch {
            print("\(Self.self): ❌ Failed to insert: \(error.localizedDescription)")
            return .failure(.insertFailed(error.localizedDescription))
        }
    }

    func updateFolder(_ folder: Folder) -> Result<Void, CoreDataError> {
        let request = FolderEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@ AND deletedAt == nil", folder.id as CVarArg)
        request.fetchLimit = 1

        do {
            guard let entity = try context.fetch(request).first else {
                print("\(Self.self): ❌ Failed to update: Entity not found")
                return .failure(.entityNotFound)
            }

            entity.title = folder.title
            entity.depth = Int16(folder.depth)
            entity.updatedAt = folder.updatedAt

            if entity.parentFolder?.id != folder.parentFolderID {
                if let parentID = folder.parentFolderID {
                    let result = fetchFolder(by: parentID)

                    switch result {
                    case .success(let parentEntity):
                        entity.parentFolder = parentEntity
                    case .failure(let error):
                        print("\(Self.self): ❌ Failed to update: Entity not found")
                        return .failure(.updateFailed(error.localizedDescription))
                    }
                } else {
                    entity.parentFolder = nil
                }
            }

            try context.save()
            print("\(Self.self): ✅ Update successfully")
            return .success(())
        } catch {
            print("\(Self.self): ❌ Failed to update: \(error.localizedDescription)")
            return .failure(.updateFailed(error.localizedDescription))
        }
    }

    func deleteFolder(_ folder: Folder) -> Result<Void, CoreDataError> {
        let request = FolderEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@ AND deletedAt == nil", folder.id as CVarArg)
        request.fetchLimit = 1

        do {
            guard let entity = try context.fetch(request).first else {
                print("\(Self.self): ❌ Failed to delete: Entity not found")
                return .failure(.entityNotFound)
            }

            deleteFolder(entity, deletedAt: folder.deletedAt)

            try context.save()
            print("\(Self.self): ✅ Delete successfully")
            return .success(())
        } catch {
            print("\(Self.self): ❌ Failed to delete: \(error.localizedDescription)")
            return .failure(.updateFailed(error.localizedDescription))
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

#if DEBUG
extension DefaultFolderStorage {
    func fetchAllFoldersForDebug() -> [FolderEntity]? {
        try? context.fetch(FolderEntity.fetchRequest())
    }
}
#endif
