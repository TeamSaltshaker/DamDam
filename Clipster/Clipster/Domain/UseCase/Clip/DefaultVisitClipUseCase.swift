import Foundation

final class DefaultVisitClipUseCase: VisitClipUseCase {
    private let clipRepository: ClipRepository

    init(clipRepository: ClipRepository) {
        self.clipRepository = clipRepository
    }

    func execute(clip: Clip) async -> Result<Void, Error> {
        let visitedClip = Clip(
            id: clip.id,
            folderID: clip.folderID,
            urlMetadata: clip.urlMetadata,
            memo: clip.memo,
            lastVisitedAt: Date(),
            createdAt: clip.createdAt,
            updatedAt: Date(),
            deletedAt: clip.deletedAt
        )

        return await clipRepository.updateClip(visitedClip).mapError { $0 as Error }
    }
}
