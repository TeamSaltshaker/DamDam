final class DefaultSortFoldersUseCase: SortFoldersUseCase {
    func execute(_ folders: [Folder], by option: FolderSortOption) -> [Folder] {
        folders.sorted {
            switch option {
            case .title(let direction):
                return SortHelper.compare($0.title, $1.title, direction)
            case .createdAt(let direction):
                return SortHelper.compare($0.createdAt, $1.createdAt, direction)
            case .updatedAt(let direction):
                return SortHelper.compare($0.updatedAt, $1.updatedAt, direction)
            }
        }
    }
}
