import Foundation

final class DefaultDeleteFolderUseCase: DeleteFolderUseCase {
    private let folderRepository: FolderRepository

    init(folderRepository: FolderRepository) {
        self.folderRepository = folderRepository
    }

    func execute(_ folder: Folder) async -> Result<Void, Error> {
        let deletedFolder  = Folder(
            id: folder.id,
            parentFolderID: folder.parentFolderID,
            title: folder.title,
            depth: folder.depth,
            folders: folder.folders,
            clips: folder.clips,
            createdAt: folder.createdAt,
            updatedAt: folder.updatedAt,
            deletedAt: Date()
        )

        return await folderRepository.deleteFolder(deletedFolder).mapError { $0 as Error }
    }
}
