protocol FetchFolderSortUseCase {
    func execute() async -> Result<FolderSortOption, Error>
}
