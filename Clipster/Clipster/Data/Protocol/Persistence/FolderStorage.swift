import CoreData

protocol FolderStorage {
    func fetchFolder(predicate: NSPredicate) async -> Result<Folder, CoreDataError>
    func fetchFolders(predicate: NSPredicate, fetchLimit: Int) async -> Result<[Folder], CoreDataError>
    func insertFolder(_ folder: Folder) async -> Result<Void, CoreDataError>
    func updateFolder(_ folder: Folder) async -> Result<Void, CoreDataError>
    func deleteFolder(_ folder: Folder) async -> Result<Void, CoreDataError>
}
