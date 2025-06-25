protocol VisitClipUseCase {
    func execute(clip: Clip) async -> Result<Void, Error>
}
