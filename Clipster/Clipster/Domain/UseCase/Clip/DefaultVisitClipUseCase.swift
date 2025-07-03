import Foundation

final class DefaultVisitClipUseCase: VisitClipUseCase {
    private let clipRepository: ClipRepository
    private let userDefaults: UserDefaults
    private let key = "recentVisitedClips"

    init(clipRepository: ClipRepository, userDefaults: UserDefaults) {
        self.clipRepository = clipRepository
        self.userDefaults = userDefaults
    }

    func execute(clip: Clip) async -> Result<Void, Error> {
        let id = clip.id.uuidString
        var ids = userDefaults.stringArray(forKey: key) ?? []
        ids.removeAll { $0 == id }
        ids.insert(id, at: 0)
        ids = Array(ids.prefix(10))

        userDefaults.set(ids, forKey: key)

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
