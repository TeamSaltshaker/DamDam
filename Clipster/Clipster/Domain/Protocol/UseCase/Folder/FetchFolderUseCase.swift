import Foundation

protocol FetchFolderUseCase {
    func execute(id: UUID) async -> Result<Folder, Error>
}
