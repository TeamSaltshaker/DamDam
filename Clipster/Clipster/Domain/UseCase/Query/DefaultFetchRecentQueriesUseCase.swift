final class DefaultFetchRecentQueriesUseCase: FetchRecentQueriesUseCase {
    func execute() async -> Result<[String], Error> {
        .success([])
    }
}
