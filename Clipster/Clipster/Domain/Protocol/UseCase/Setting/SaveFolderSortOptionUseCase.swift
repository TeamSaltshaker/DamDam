protocol SaveFolderSortOptionUseCase {
    func execute(_ option: FolderSortOption) async -> Result<Void, Error>
}
