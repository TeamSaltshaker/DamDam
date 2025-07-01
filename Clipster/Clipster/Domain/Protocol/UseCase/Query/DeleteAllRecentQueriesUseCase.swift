protocol DeleteAllRecentQueriesUseCase {
    func execute() async -> Result<Void, Error>
}
