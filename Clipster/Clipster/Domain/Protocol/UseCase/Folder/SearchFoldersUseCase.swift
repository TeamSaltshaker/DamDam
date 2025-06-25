protocol SearchFoldersUseCase {
    func execute(query: String, in folders: [Folder]) -> [Folder]
}
