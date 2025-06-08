import Foundation

protocol FetchTopLevelFoldersUseCase {
    func execute(parentFolderID: UUID?) async -> Result<Folder, Error>
}
