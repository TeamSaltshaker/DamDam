import CoreData

final class DefaultFolderStorage: FolderStorage {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchFolder(by id: UUID) -> Result<FolderEntity, CoreDataError> {
        let request = FolderEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
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

    @discardableResult
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
}
