protocol FetchClipSortUseCase {
    func execute() async -> Result<ClipSortOption, Error>
}
