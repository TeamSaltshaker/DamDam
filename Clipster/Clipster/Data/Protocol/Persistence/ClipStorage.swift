import Foundation

protocol ClipStorage {
    func fetchClip(predicate: NSPredicate) async -> Result<Clip, CoreDataError>
    func fetchClips(predicate: NSPredicate, fetchLimit: Int) async -> Result<[Clip], CoreDataError>
    func insertClip(_ clip: Clip) async -> Result<Void, CoreDataError>
    func updateClip(_ clip: Clip) async -> Result<Void, CoreDataError>
    func deleteClip(_ clip: Clip) async -> Result<Void, CoreDataError>
}
