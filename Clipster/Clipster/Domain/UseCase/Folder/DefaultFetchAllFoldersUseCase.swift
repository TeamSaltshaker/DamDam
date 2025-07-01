import Foundation

final class DefaultFetchAllFoldersUseCase: FetchAllFoldersUseCase {
    private let folderRepository: FolderRepository

    init(folderRepository: FolderRepository) {
        self.folderRepository = folderRepository
    }

    func execute() async -> Result<[Folder], Error> {
        .success([])
    }
}
