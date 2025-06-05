protocol ClipStorage {
    func insertClip(_ clip: Clip) -> Result<Void, CoreDataError>
}
