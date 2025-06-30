protocol FetchRecentQueriesUseCase {
    func execute() async -> Result<[String], Error>
}
