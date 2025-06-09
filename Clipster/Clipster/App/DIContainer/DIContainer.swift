import CoreData
import Foundation

final class DIContainer {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext? = nil) {
        self.context = context ?? CoreDataStack.shared.context
    }

    func makeClipStorage() -> ClipStorage {
         DefaultClipStorage(context: context)
     }

    func makeFolderStorage() -> FolderStorage {
         DefaultFolderStorage(context: context)
     }

    func makeClipRepository() -> ClipRepository {
        DefaultClipRepository(
            storage: makeClipStorage(),
            mapper: DomainMapper()
        )
    }

    func makeFolderRepository() -> FolderRepository {
        DefaultFolderRepository(
            storage: makeFolderStorage(),
            mapper: DomainMapper()
        )
    }

    func makeURLMetadataRepository() -> URLMetadataRepository {
        DefaultURLMetadataRepository()
    }

    func makeURLValidationRepository() -> URLValidationRepository {
        DefaultURLValidationRepository()
    }
}
