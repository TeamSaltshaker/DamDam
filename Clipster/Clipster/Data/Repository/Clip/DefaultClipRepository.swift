import Foundation

final class DefaultClipRepository: ClipRepository {
    private let storage: ClipStorage
    private let cache: FolderClipCache

    init(storage: ClipStorage, cache: FolderClipCache) {
        self.storage = storage
        self.cache = cache
    }

    func fetchClip(by id: UUID) async -> Result<Clip, DomainError> {
        if await cache.isClipsInitialized {
            guard let clip = await cache.clip(by: id) else {
                return .failure(.entityNotFound)
            }
            return .success(clip)
        } else {
            return await storage.fetchClip(by: id)
                .mapError { _ in .fetchFailed }
        }
    }

    func fetchTopLevelClips() async -> Result<[Clip], DomainError> {
        if await cache.isClipsInitialized {
            let clips = await cache.clips()
            return .success(clips.filter {
                $0.folderID == nil && $0.deletedAt == nil
            })
        } else {
            return await storage.fetchTopLevelClips()
                .mapError { _ in .fetchFailed }
        }
    }

    func fetchUnvisitedClips() async -> Result<[Clip], DomainError> {
        if await cache.isClipsInitialized {
            let clips = await cache.clips()
            return .success(clips.filter {
                $0.lastVisitedAt == nil && $0.deletedAt == nil
            })
        } else {
            return await storage.fetchUnvisitedClips()
                .mapError { _ in .fetchFailed }
        }
    }

    func insertClip(_ clip: Clip) async -> Result<Void, DomainError> {
        let result = await storage.insertClip(clip)

        switch result {
        case .success:
            if await cache.isClipsInitialized {
                await cache.setClip(clip)
            }
            return .success(())
        case .failure:
            return .failure(.insertFailed)
        }
    }

    func updateClip(_ clip: Clip) async -> Result<Void, DomainError> {
        let result = await storage.updateClip(clip)

        switch result {
        case .success:
            if await cache.isClipsInitialized {
                await cache.setClip(clip)
            }
            return .success(())
        case .failure:
            return .failure(.updateFailed)
        }
    }

    func deleteClip(_ clip: Clip) async -> Result<Void, DomainError> {
        let result = await storage.deleteClip(clip)

        switch result {
        case .success:
            if await cache.isClipsInitialized {
                await cache.setClip(clip)
            }
            return .success(())
        case .failure:
            return .failure(.deleteFailed)
        }
    }
}
