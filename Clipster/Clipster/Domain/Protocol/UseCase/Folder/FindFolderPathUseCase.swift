protocol FindFolderPathUseCase {
    func execute(to target: Folder, in folders: [Folder]) -> [Folder]?
}
