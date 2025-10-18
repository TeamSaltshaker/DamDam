import Foundation

final class DefaultClipRepository: ClipRepository {
    private let storage: ClipStorage

    init(storage: ClipStorage) {
        self.storage = storage
    }

    func fetchClip(by id: UUID) async -> Result<Clip, DomainError> {
        let predicate = NSPredicate(format: "id == %@ AND deletedAt == nil", id as CVarArg)

        return await storage.fetchClip(predicate: predicate)
            .mapError { _ in .fetchFailed }
    }

    func fetchAllClips() async -> Result<[Clip], DomainError> {
        let predicate = NSPredicate(format: "deletedAt == nil")

        return await storage.fetchClips(predicate: predicate, fetchLimit: 0)
            .mapError { _ in .fetchFailed }
    }

    func fetchTopLevelClips() async -> Result<[Clip], DomainError> {
        let predicate = NSPredicate(format: "folder == nil AND deletedAt == nil")

        return await storage.fetchClips(predicate: predicate, fetchLimit: 0)
            .mapError { _ in .fetchFailed }
    }

    func fetchUnvisitedClips() async -> Result<[Clip], DomainError> {
        let predicate = NSPredicate(format: "lastVisitedAt == nil AND deletedAt == nil")

        return await storage.fetchClips(predicate: predicate, fetchLimit: 0)
            .mapError { _ in .fetchFailed }
    }

    func fetchRecentVisitedClips(for ids: [UUID]) async -> Result<[Clip], DomainError> {
        let predicate = NSPredicate(format: "id IN %@ AND deletedAt == nil", ids)

        return await storage.fetchClips(predicate: predicate, fetchLimit: 0)
            .mapError { _ in .fetchFailed }
    }

    func insertClip(_ clip: Clip) async -> Result<Void, DomainError> {
        await storage.insertClip(clip)
            .mapError { _ in .insertFailed }
    }

    func updateClip(_ clip: Clip) async -> Result<Void, DomainError> {
        await storage.updateClip(clip)
            .mapError { _ in .updateFailed }
    }

    func deleteClip(_ clip: Clip) async -> Result<Void, DomainError> {
        await storage.deleteClip(clip)
            .mapError { _ in .deleteFailed }
    }
}
