import Foundation

protocol ClipRepository {
    func fetchClip(by id: UUID) async -> Result<Clip, DomainError>
    func fetchTopLevelClips() async -> Result<[Clip], DomainError>
    func fetchUnvisitedClips() async -> Result<[Clip], DomainError>
    func fetchRecentVisitedClips(for ids: [UUID]) async -> Result<[Clip], DomainError>
    func insertClip(_ clip: Clip) async -> Result<Void, DomainError>
    func updateClip(_ clip: Clip) async -> Result<Void, DomainError>
    func deleteClip(_ clip: Clip) async -> Result<Void, DomainError>
}
