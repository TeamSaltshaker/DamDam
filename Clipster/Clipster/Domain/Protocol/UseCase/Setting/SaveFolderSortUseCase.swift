protocol SaveFolderSortUseCase {
    func execute(_ option: FolderSortOption) async -> Result<Void, Error>
}
