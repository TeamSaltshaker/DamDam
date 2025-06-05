import Foundation

protocol FolderStorage {
    func fetchFolder(by id: UUID) -> Result<FolderEntity, CoreDataError>
}
