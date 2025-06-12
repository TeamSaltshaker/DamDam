import Foundation

final class DefaultFetchClipUseCase: FetchClipUseCase {
    private let clipRepository: ClipRepository

     init(clipRepository: ClipRepository) {
         self.clipRepository = clipRepository
     }

    func execute(id: UUID) async -> Result<Clip, Error> {
        await clipRepository.fetchClip(by: id).mapError { $0 as Error }
    }
}
