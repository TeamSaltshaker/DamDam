import Foundation

protocol FetchFolderUseCase {
    func execute(parentFolderID: UUID?) async -> Result<Folder, Error>
}
