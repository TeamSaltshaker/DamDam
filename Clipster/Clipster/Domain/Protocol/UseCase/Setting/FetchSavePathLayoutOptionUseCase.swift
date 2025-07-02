protocol FetchSavePathLayoutOptionUseCase {
    func execute() async -> Result<SavePathOption, Error>
}
