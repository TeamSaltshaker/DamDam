protocol FetchUnvisitedClipsUseCase {
    func execute() async -> Result<[Clip], Error>
}
