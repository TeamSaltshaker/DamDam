final class DefaultUpdateFolderUseCase: UpdateFolderUseCase {
    private let folderRepository: FolderRepository

    init(folderRepository: FolderRepository) {
        self.folderRepository = folderRepository
    }

    func execute(_ folder: Folder) async -> Result<Void, Error> {
        await folderRepository.updateFolder(folder).mapError { $0 as Error }
    }
}
