import Foundation

final class DefaultFetchFolderUseCase: FetchFolderUseCase {
    private let folderRepository: FolderRepository

    init(folderRepository: FolderRepository) {
        self.folderRepository = folderRepository
    }

    func execute(id: UUID) async -> Result<Folder, Error> {
        await folderRepository.fetchFolder(by: id)
            .map { recursivelySortFolder($0) }
            .mapError { $0 as Error }
    }

    private func recursivelySortFolder(_ folder: Folder) -> Folder {
        let sortedFolders = folder.folders
            .map(recursivelySortFolder)
            .sorted { $0.createdAt < $1.createdAt }
        let sortedClips = folder.clips
            .sorted { $0.createdAt > $1.createdAt }

        return Folder(
            id: folder.id,
            parentFolderID: folder.parentFolderID,
            title: folder.title,
            depth: folder.depth,
            folders: sortedFolders,
            clips: sortedClips,
            createdAt: folder.createdAt,
            updatedAt: folder.updatedAt,
            deletedAt: folder.deletedAt,
        )
    }
}
