protocol FetchTopLevelClipsUseCase {
    func execute() async -> Result<[Clip], Error>
}
