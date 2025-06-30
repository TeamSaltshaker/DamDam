final class DefaultSaveRecentQueryUseCase: SaveRecentQueryUseCase {
    func execute(_ query: String) async -> Result<Void, Error> {
        .success(())
    }
}
