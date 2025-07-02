protocol FetchSavePathLayoutUseCase {
    func execute() async -> Result<SavePathOption, Error>
}
