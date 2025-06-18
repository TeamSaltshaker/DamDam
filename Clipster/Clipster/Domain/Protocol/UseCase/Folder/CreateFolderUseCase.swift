protocol CreateFolderUseCase {
    func execute(_ folder: Folder) async -> Result<Void, Error>
}
