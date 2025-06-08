protocol CheckURLValidityUseCase {
    func execute(urlString: String) async throws -> Bool
}
