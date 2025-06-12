final class DefaultFetchTopLevelFoldersUseCase: FetchTopLevelFoldersUseCase {
    private let folderRepository: FolderRepository

    init(folderRepository: FolderRepository) {
        self.folderRepository = folderRepository
    }

    func execute() async -> Result<[Folder], Error> {
        await folderRepository.fetchTopLevelFolders()
            .map { folders in
                folders.sorted { $0.createdAt < $1.createdAt }
            }
            .mapError { $0 as Error }
    }
}
