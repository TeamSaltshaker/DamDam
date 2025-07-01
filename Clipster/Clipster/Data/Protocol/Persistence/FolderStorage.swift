import Foundation

protocol FolderStorage {
    func fetchAllFolders() async -> Result<[Folder], CoreDataError>
    func fetchFolder(by id: UUID) async -> Result<Folder, CoreDataError>
    func insertFolder(_ folder: Folder) async -> Result<Void, CoreDataError>
    func updateFolder(_ folder: Folder) async -> Result<Void, CoreDataError>
    func deleteFolder(_ folder: Folder) async -> Result<Void, CoreDataError>
}
