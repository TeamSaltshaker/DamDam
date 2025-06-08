protocol CheckURLValidityUseCase {
    func execute(urlString: String) async -> Result<Bool, Error>
}
