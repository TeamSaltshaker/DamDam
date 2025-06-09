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
}
