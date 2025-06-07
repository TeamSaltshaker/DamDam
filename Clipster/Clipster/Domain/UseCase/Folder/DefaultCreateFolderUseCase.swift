final class DefaultCreateFolderUseCase: CreateFolderUseCase {
    private let folderRepository: FolderRepository

    init(folderRepository: FolderRepository) {
        self.folderRepository = folderRepository
    }

    func execute(_ folder: Folder) async -> Result<Void, DomainError> {
        folderRepository.insertFolder(folder)
    }
}
