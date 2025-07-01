protocol DeleteRecentQueryUseCase {
    func execute(_ query: String) async -> Result<Void, Error>
}
