protocol SaveClipSortOptionUseCase {
    func execute(_ option: ClipSortOption) async -> Result<Void, Error>
}
