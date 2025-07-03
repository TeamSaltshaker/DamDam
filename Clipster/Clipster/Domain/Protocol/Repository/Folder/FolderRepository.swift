import Foundation

protocol FolderRepository {
    func fetchFolder(by id: UUID) async -> Result<Folder, DomainError>
    func fetchAllFolders() async -> Result<[Folder], DomainError>
    func fetchTopLevelFolders() async -> Result<[Folder], DomainError>
    func insertFolder(_ folder: Folder) async -> Result<Void, DomainError>
    func updateFolder(_ folder: Folder) async -> Result<Void, DomainError>
    func deleteFolder(_ folder: Folder) async -> Result<Void, DomainError>
}
