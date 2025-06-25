protocol SearchClipsUseCase {
    func execute(query: String, in clips: [Clip]) -> [Clip]
}
