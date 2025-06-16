final class DefaultUpdateClipUseCase: UpdateClipUseCase {
    let clipRepository: ClipRepository

    init(clipRepository: ClipRepository) {
        self.clipRepository = clipRepository
    }

    func execute(clip: Clip) async -> Result<Void, Error> {
        await clipRepository.updateClip(clip).mapError { $0 as Error }
    }
}
