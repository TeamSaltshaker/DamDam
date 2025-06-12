import Foundation

final class DefaultFetchFolderUseCase: FetchFolderUseCase {
    private let folderRepository: FolderRepository

    init(folderRepository: FolderRepository) {
        self.folderRepository = folderRepository
    }

    func execute(id: UUID) async -> Result<Folder, Error> {
        await folderRepository.fetchFolder(by: id)
            .map { folder in
                Folder(
                    id: folder.id,
                    parentFolderID: folder.parentFolderID,
                    title: folder.title,
                    depth: folder.depth,
                    folders: folder.folders.sorted { $0.createdAt < $1.createdAt },
                    clips: folder.clips.sorted { $0.createdAt > $1.createdAt },
                    createdAt: folder.createdAt,
                    updatedAt: folder.updatedAt,
                    deletedAt: folder.deletedAt,
                )
            }
            .mapError { $0 as Error }
    }
}
