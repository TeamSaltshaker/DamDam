final class DefaultDeleteRecentQueryUseCase: DeleteRecentQueryUseCase {
    func execute(_ query: String) async -> Result<Void, Error> {
        .success(())
    }
}
