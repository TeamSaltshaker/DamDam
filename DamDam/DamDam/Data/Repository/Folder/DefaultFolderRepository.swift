import Foundation

final class DefaultFolderRepository: FolderRepository {
    private let storage: FolderStorage

    init(storage: FolderStorage) {
        self.storage = storage
    }

    func fetchFolder(by id: UUID) async -> Result<Folder, DomainError> {
        await storage.fetchFolder(by: id)
            .mapError { _ in .unknownError }
    }

    func fetchTopLevelFolders() async -> Result<[Folder], DomainError> {
        await storage.fetchTopLevelFolders()
            .mapError { _ in .unknownError }
    }

    func insertFolder(_ folder: Folder) async -> Result<Void, DomainError> {
        await storage.insertFolder(folder)
            .mapError { _ in .unknownError }
    }

    func updateFolder(_ folder: Folder) async -> Result<Void, DomainError> {
        await storage.updateFolder(folder)
            .mapError { _ in .unknownError }
    }

    func deleteFolder(_ folder: Folder) async -> Result<Void, DomainError> {
        await storage.deleteFolder(folder)
            .mapError { _ in .unknownError }
    }
}
