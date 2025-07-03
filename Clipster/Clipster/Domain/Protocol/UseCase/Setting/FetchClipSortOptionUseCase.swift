protocol FetchClipSortOptionUseCase {
    func execute() async -> Result<ClipSortOption, Error>
}
