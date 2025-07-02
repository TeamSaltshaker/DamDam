protocol SaveClipSortUseCase {
    func execute(_ option: ClipSortOption) async -> Result<Void, Error>
}
