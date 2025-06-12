final class DefaultUpdateFolderUseCase: UpdateFolderUseCase {
    private let folderRepository: FolderRepository

    init(folderRepository: FolderRepository) {
        self.folderRepository = folderRepository
    }

    func execute(_ folder: Folder) async -> Result<Void, DomainError> {
        await folderRepository.updateFolder(folder)
    }
}
