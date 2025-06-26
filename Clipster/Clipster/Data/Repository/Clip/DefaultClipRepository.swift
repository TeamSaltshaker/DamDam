import Foundation

final class DefaultClipRepository: ClipRepository {
    private let storage: ClipStorage
    private let cache: FolderClipCache

    init(storage: ClipStorage, cache: FolderClipCache) {
        self.storage = storage
        self.cache = cache
    }

    func fetchClip(by id: UUID) async -> Result<Clip, DomainError> {
        await storage.fetchClip(by: id)
            .mapError { _ in .unknownError }
    }

    func fetchTopLevelClips() async -> Result<[Clip], DomainError> {
        await storage.fetchTopLevelClips()
            .mapError { _ in .unknownError }
    }

    func fetchUnvisitedClips() async -> Result<[Clip], DomainError> {
        await storage.fetchUnvisitedClips()
            .mapError { _ in .unknownError }
    }

    func createClip(_ clip: Clip) async -> Result<Void, DomainError> {
        await storage.insertClip(clip)
            .mapError { _ in .unknownError }
    }

    func updateClip(_ clip: Clip) async -> Result<Void, DomainError> {
        await storage.updateClip(clip)
            .mapError { _ in .unknownError }
    }

    func deleteClip(_ clip: Clip) async -> Result<Void, DomainError> {
        await storage.deleteClip(clip)
            .mapError { _ in .unknownError }
    }
}
