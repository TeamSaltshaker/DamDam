protocol FetchRecentVisitedClipsUseCase {
    func execute() async -> Result<[Clip], Error>
}
