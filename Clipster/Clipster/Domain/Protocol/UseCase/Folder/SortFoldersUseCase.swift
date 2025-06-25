protocol SortFoldersUseCase {
    func execute(_ folders: [Folder], by option: FolderSortOption) -> [Folder]
}
