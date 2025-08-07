import Foundation

final class DefaultVisitClipUseCase: VisitClipUseCase {
    private let clipRepository: ClipRepository
    private let userDefaultsRepository: UserDefaultsRepository

    init(clipRepository: ClipRepository, userDefaultsRepository: UserDefaultsRepository) {
        self.clipRepository = clipRepository
        self.userDefaultsRepository = userDefaultsRepository
    }

    func execute(clip: Clip) async -> Result<Void, Error> {
        let id = clip.id.uuidString
        var ids = userDefaultsRepository.recentVisitedClips()
        ids.removeAll { $0 == id }
        ids.insert(id, at: 0)
        ids = Array(ids.prefix(10))

        userDefaultsRepository.setRecentVisitedClips(ids)

        let visitedClip = Clip(
            id: clip.id,
            folderID: clip.folderID,
            url: clip.url,
            title: clip.title,
            subtitle: clip.subtitle,
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
