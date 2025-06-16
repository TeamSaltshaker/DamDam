import Foundation

final class DefaultClipRepository: ClipRepository {
    private let storage: ClipStorage

    init(storage: ClipStorage) {
        self.storage = storage
    }

    func fetchClip(by id: UUID) async -> Result<Clip, DomainError> {
        await storage.fetchClip(by: id)
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
