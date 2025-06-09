final class DefaultDeleteFolderUseCase: DeleteFolderUseCase {
    private let folderRepository: FolderRepository

    init(folderRepository: FolderRepository) {
        self.folderRepository = folderRepository
    }

    func execute(_ folder: Folder) async -> Result<Void, Error> {
        folderRepository.deleteFolder(folder).mapError { $0 as Error }
    }
}
