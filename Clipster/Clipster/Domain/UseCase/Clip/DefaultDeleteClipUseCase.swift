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
            description: clip.description,
            memo: clip.memo,
            thumbnailImageURL: clip.thumbnailImageURL,
            screenshotData: clip.screenshotData,
            createdAt: clip.createdAt,
            lastVisitedAt: clip.lastVisitedAt,
            updatedAt: clip.updatedAt,
            deletedAt: Date.now,
        )

        return await clipRepository.deleteClip(deletedClip).mapError { $0 as Error }
    }
}
