final class DefaultFilterSubfoldersUseCase: FilterSubfoldersUseCase {
    func execute(_ remove: Folder, from tree: [Folder]) -> [Folder] {
        tree.compactMap { folder -> Folder? in
            if folder.id == remove.id {
                return nil
            }

            let subfolders = execute(remove, from: folder.folders)

            return Folder(
                id: folder.id,
                parentFolderID: folder.parentFolderID,
                title: folder.title,
                depth: folder.depth,
                folders: subfolders,
                clips: folder.clips,
                createdAt: folder.createdAt,
                updatedAt: folder.updatedAt,
                deletedAt: folder.deletedAt
            )
        }
    }
}
