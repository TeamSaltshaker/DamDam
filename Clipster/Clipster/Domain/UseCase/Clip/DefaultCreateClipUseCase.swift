import Foundation

final class DefaultCreateClipUseCase: CreateClipUseCase {
    let clipRepository: ClipRepository

    init(clipRepository: ClipRepository) {
        self.clipRepository = clipRepository
    }

    func execute(_ clip: Clip) async -> Result<Void, Error> {
        await clipRepository.insertClip(clip).mapError { $0 as Error }
    }
}
