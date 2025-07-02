protocol SaveSavePathVisibilityUseCase {
    func execute(_ option: SavePathOption) async -> Result<Void, Error>
}
