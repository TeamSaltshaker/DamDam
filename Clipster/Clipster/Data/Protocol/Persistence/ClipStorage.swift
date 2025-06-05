import Foundation

protocol ClipStorage {
    func fetchClip(by id: UUID) -> Result<ClipEntity, CoreDataError>
    func fetchUnvisitedClips() -> Result<[ClipEntity], CoreDataError>
    func insertClip(_ clip: Clip) -> Result<Void, CoreDataError>
}
