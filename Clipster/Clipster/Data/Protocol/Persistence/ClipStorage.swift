import Foundation

protocol ClipStorage {
    func fetchClip(by id: UUID) -> Result<ClipEntity, CoreDataError>
    func fetchUnvisitedClips() -> Result<[ClipEntity], CoreDataError>
    func insertClip(_ clip: Clip) -> Result<Void, CoreDataError>
    func updateClip(_ clip: Clip) -> Result<Void, CoreDataError>
    func deleteClip(_ clip: Clip) -> Result<Void, CoreDataError>
}
