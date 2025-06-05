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
}
