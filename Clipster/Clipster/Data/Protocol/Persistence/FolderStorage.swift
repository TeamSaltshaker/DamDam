import Foundation

protocol FolderStorage {
    func fetchFolder(by id: UUID) -> Result<FolderEntity, CoreDataError>
    func fetchTopLevelFolders() -> Result<[FolderEntity], CoreDataError>
    func insertFolder(_ folder: Folder) -> Result<Void, CoreDataError>
    func updateFolder(_ folder: Folder) -> Result<Void, CoreDataError>
}
