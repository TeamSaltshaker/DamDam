final class DefaultDeleteClipUseCase: DeleteClipUseCase {
    private let clipRepository: ClipRepository

     init(clipRepository: ClipRepository) {
         self.clipRepository = clipRepository
     }

    func execute(_ clip: Clip) async -> Result<Void, Error> {
        clipRepository.deleteClip(clip).mapError { $0 as Error }
    }
}
