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
        let query: (Clip) -> Bool = { clip in
            clip.folderID == nil && clip.deletedAt == nil
        }

        if await cache.isClipsInitialized {
            let clips = await cache.clips()
            return .success(clips.filter(query))
        } else {
            let result = await storage.fetchAllClips()

            switch result {
            case .success(let clips):
                return .success(clips.filter(query))
            case .failure:
                return .failure(.fetchFailed)
            }
        }
    }

    func fetchUnvisitedClips() async -> Result<[Clip], DomainError> {
        let query: (Clip) -> Bool = { clip in
            clip.lastVisitedAt == nil && clip.deletedAt == nil
        }

        if await cache.isClipsInitialized {
            let clips = await cache.clips()
            return .success(clips.filter(query))
        } else {
            let result = await storage.fetchAllClips()

            switch result {
            case .success(let clips):
                return .success(clips.filter(query))
            case .failure:
                return .failure(.fetchFailed)
            }
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
