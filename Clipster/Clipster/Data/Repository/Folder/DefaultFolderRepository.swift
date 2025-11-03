import Foundation

final class DefaultFolderRepository: FolderRepository {
    private let storage: FolderStorage

    init(storage: FolderStorage) {
        self.storage = storage
    }

    func fetchFolder(by id: UUID) async -> Result<Folder, DomainError> {
        let predicate = NSPredicate(format: "id == %@ AND deletedAt == nil", id as CVarArg)

        return await storage.fetchFolder(predicate: predicate)
            .mapError { _ in .fetchFailed }
    }

    func fetchAllFolders() async -> Result<[Folder], DomainError> {
        let predicate = NSPredicate(format: "deletedAt == nil")

        return await storage.fetchFolders(predicate: predicate, fetchLimit: 0)
            .mapError { _ in .fetchFailed }
    }

    func fetchTopLevelFolders() async -> Result<[Folder], DomainError> {
        let predicate = NSPredicate(format: "parentFolder == nil AND deletedAt == nil")

        return await storage.fetchFolders(predicate: predicate, fetchLimit: 0)
            .mapError { _ in .fetchFailed }
    }

    func insertFolder(_ folder: Folder) async -> Result<Void, DomainError> {
        await storage.insertFolder(folder)
            .mapError { _ in .insertFailed }
    }

    func updateFolder(_ folder: Folder) async -> Result<Void, DomainError> {
        await storage.updateFolder(folder)
            .mapError { _ in .updateFailed }
    }

    func deleteFolder(_ folder: Folder) async -> Result<Void, DomainError> {
        await storage.deleteFolder(folder)
            .mapError { _ in .deleteFailed }
    }
}
