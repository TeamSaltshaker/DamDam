final class DefaultFetchTopLevelFoldersUseCase: FetchTopLevelFoldersUseCase {
    private let folderRepository: FolderRepository

    init(folderRepository: FolderRepository) {
        self.folderRepository = folderRepository
    }

    func execute() async -> Result<[Folder], Error> {
        folderRepository.fetchTopLevelFolders().mapError { $0 as Error }
    }
}
