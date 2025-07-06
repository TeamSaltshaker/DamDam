import Foundation

protocol ClipService {
    func fetchClip(by id: UUID) async -> Result<ClipDTO, DatabaseError>
    func fetchAllClips() async -> Result<[ClipDTO], DatabaseError>
    func fetchTopLevelClips() async -> Result<[ClipDTO], DatabaseError>
    func fetchUnvisitedClips() async -> Result<[ClipDTO], DatabaseError>
    func fetchRecentVisitedClips(for ids: [UUID]) async -> Result<[ClipDTO], DatabaseError>
    func insertClip(_ dto: ClipDTO) async -> Result<ClipDTO, DatabaseError>
    func updateClip(_ dto: ClipDTO) async -> Result<ClipDTO, DatabaseError>
    func deleteClip(_ dto: ClipDTO) async -> Result<ClipDTO, DatabaseError>
}
