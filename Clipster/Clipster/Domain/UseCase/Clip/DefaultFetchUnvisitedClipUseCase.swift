final class DefaultFetchUnvisitedClipUseCase: FetchUnvisitedClipUseCase {
    func execute() async -> Result<[Clip], Error> {
        .success([])
    }
}
