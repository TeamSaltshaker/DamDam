final class DefaultFetchTopLevelFoldersUseCase: FetchTopLevelFoldersUseCase {
    private let folderRepository: FolderRepository

    init(folderRepository: FolderRepository) {
        self.folderRepository = folderRepository
    }

    func execute() async -> Result<[Folder], Error> {
        await folderRepository.fetchTopLevelFolders()
            .map { folders in
                folders
                    .map(recursivelySortFolder)
                    .sorted { $0.createdAt < $1.createdAt }
            }
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
