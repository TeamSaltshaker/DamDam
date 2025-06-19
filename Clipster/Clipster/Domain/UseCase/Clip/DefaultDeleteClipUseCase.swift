import Foundation

final class DefaultDeleteClipUseCase: DeleteClipUseCase {
    private let clipRepository: ClipRepository

    init(clipRepository: ClipRepository) {
        self.clipRepository = clipRepository
    }

    func execute(_ clip: Clip) async -> Result<Void, Error> {
        let deletedClip = Clip(
            id: clip.id,
            folderID: clip.folderID,
            url: clip.url,
            title: clip.title,
            memo: clip.memo,
            thumbnailImageURL: clip.thumbnailImageURL,
            screenshotData: clip.screenshotData,
            lastVisitedAt: clip.lastVisitedAt,
            createdAt: clip.createdAt,
            updatedAt: clip.updatedAt,
            deletedAt: Date.now,
        )

        return await clipRepository.deleteClip(deletedClip).mapError { $0 as Error }
    }
}
