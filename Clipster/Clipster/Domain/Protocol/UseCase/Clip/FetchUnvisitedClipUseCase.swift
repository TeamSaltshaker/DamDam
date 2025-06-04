protocol FetchUnvisitedClipUseCase {
    func execute() async -> Result<[Clip], Error>
}
