protocol SaveSavePathLayoutOptionUseCase {
    func execute(_ option: SavePathOption) async -> Result<Void, Error>
}
