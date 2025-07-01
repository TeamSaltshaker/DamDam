final class DefaultDeleteAllRecentQueriesUseCase: DeleteAllRecentQueriesUseCase {
    func execute() async -> Result<Void, Error> {
        .success(())
    }
}
