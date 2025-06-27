import Foundation

protocol ClipStorage {
    func fetchClip(by id: UUID) async -> Result<Clip, CoreDataError>
    func fetchTopLevelClips() async -> Result<[Clip], CoreDataError>
    func fetchUnvisitedClips() async -> Result<[Clip], CoreDataError>
    func insertClip(_ clip: Clip) async -> Result<Void, CoreDataError>
    func updateClip(_ clip: Clip) async -> Result<Void, CoreDataError>
    func deleteClip(_ clip: Clip) async -> Result<Void, CoreDataError>
}
