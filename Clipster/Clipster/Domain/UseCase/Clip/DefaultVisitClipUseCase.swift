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
            url: clip.url,
            title: clip.title,
            description: clip.description,
            memo: clip.memo,
            thumbnailImageURL: clip.thumbnailImageURL,
            screenshotData: clip.screenshotData,
            createdAt: clip.createdAt,
            lastVisitedAt: Date.now,
            updatedAt: Date.now,
            deletedAt: clip.deletedAt,
        )

        return await clipRepository.updateClip(visitedClip).mapError { $0 as Error }
    }
}
