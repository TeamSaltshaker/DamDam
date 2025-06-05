final class DefaultFetchUnvisitedClipsUseCase: FetchUnvisitedClipsUseCase {
    func execute() async -> Result<[Clip], Error> {
        .success([])
    }
}
