protocol SaveRecentQueryUseCase {
    func execute(_ query: String) async -> Result<Void, Error>
}
