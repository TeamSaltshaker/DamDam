protocol ClipStorage {
    func fetchUnvisitedClips() -> Result<[ClipEntity], CoreDataError>
    func insertClip(_ clip: Clip) -> Result<Void, CoreDataError>
}
