import Foundation

final class DefaultFetchFolderUseCase: FetchFolderUseCase {
    private let folderRepository: FolderRepository

    init(folderRepository: FolderRepository) {
        self.folderRepository = folderRepository
    }

    func execute(id: UUID) async -> Result<Folder, Error> {
        folderRepository.fetchFolder(by: id).mapError { $0 as Error }
    }
}
