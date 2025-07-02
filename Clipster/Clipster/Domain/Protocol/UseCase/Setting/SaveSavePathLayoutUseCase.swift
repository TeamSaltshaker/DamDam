protocol SaveSavePathLayoutUseCase {
    func execute(_ option: SavePathOption) async -> Result<Void, Error>
}
