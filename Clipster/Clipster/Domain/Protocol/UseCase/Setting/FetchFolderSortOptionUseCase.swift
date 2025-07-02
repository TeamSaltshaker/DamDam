protocol FetchFolderSortOptionUseCase {
    func execute() async -> Result<FolderSortOption, Error>
}
