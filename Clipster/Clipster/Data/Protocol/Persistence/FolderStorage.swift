import CoreData

protocol FolderStorage {
    func fetchFolder(by id: UUID) async -> Result<Folder, CoreDataError>
    func fetchAllFolders() async -> Result<[Folder], CoreDataError>
    func fetchTopLevelFolders() async -> Result<[Folder], CoreDataError>
    func insertFolder(_ folder: Folder) async -> Result<Void, CoreDataError>
    func updateFolder(_ folder: Folder) async -> Result<Void, CoreDataError>
    func deleteFolder(_ folder: Folder) async -> Result<Void, CoreDataError>
}
