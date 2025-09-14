import Foundation

final class DefaultClipRepository: ClipRepository {
    private let storage: ClipStorage
    private let cache: FolderClipCache?

    init(storage: ClipStorage, cache: FolderClipCache?) {
        self.storage = storage
        self.cache = cache
    }

    func fetchClip(by id: UUID) async -> Result<Clip, DomainError> {
        if let cache,
           await cache.isClipsInitialized {
            guard let clip = await cache.clip(by: id) else {
                return .failure(.entityNotFound)
            }
            return .success(clip)
        }

        let predicate = NSPredicate(format: "id == %@ AND deletedAt == nil", id as CVarArg)

        return await storage.fetchClip(predicate: predicate)
            .mapError { _ in .fetchFailed }
    }

    func fetchAllClips() async -> Result<[Clip], DomainError> {
        if let cache,
           await cache.isClipsInitialized {
            let clips = await cache.clips()
            return .success(clips.filter { $0.deletedAt == nil })
        }

        let predicate = NSPredicate(format: "deletedAt == nil")

        return await storage.fetchClips(predicate: predicate, fetchLimit: 0)
            .mapError { _ in .fetchFailed }
    }

    func fetchTopLevelClips() async -> Result<[Clip], DomainError> {
        if let cache,
           await cache.isClipsInitialized {
            let clips = await cache.clips()
            return .success(clips.filter {
                $0.folderID == nil && $0.deletedAt == nil
            })
        }

        let predicate = NSPredicate(format: "folder == nil AND deletedAt == nil")

        return await storage.fetchClips(predicate: predicate, fetchLimit: 0)
            .mapError { _ in .fetchFailed }
    }

    func fetchUnvisitedClips() async -> Result<[Clip], DomainError> {
        if let cache,
           await cache.isClipsInitialized {
            let clips = await cache.clips()
            return .success(clips.filter {
                $0.lastVisitedAt == nil && $0.deletedAt == nil
            })
        }

        let predicate = NSPredicate(format: "lastVisitedAt == nil AND deletedAt == nil")

        return await storage.fetchClips(predicate: predicate, fetchLimit: 0)
            .mapError { _ in .fetchFailed }
    }

    func fetchRecentVisitedClips(for ids: [UUID]) async -> Result<[Clip], DomainError> {
        if let cache,
           await cache.isClipsInitialized {
            let clips = await cache.clips()
            return .success(clips.filter {
                ids.contains($0.id)
            })
        }

        let predicate = NSPredicate(format: "id IN %@ AND deletedAt == nil", ids)

        return await storage.fetchClips(predicate: predicate, fetchLimit: 0)
            .mapError { _ in .fetchFailed }
    }

    func insertClip(_ clip: Clip) async -> Result<Void, DomainError> {
        let result = await storage.insertClip(clip)

        switch result {
        case .success:
            if let cache,
               await cache.isClipsInitialized {
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
            if let cache,
               await cache.isClipsInitialized {
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
            if let cache,
               await cache.isClipsInitialized {
                await cache.setClip(clip)
            }
            return .success(())
        case .failure:
            return .failure(.deleteFailed)
        }
    }
}
