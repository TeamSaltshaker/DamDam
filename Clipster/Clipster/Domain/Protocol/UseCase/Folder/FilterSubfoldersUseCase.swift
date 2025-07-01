protocol FilterSubfoldersUseCase {
    func execute(_ remove: Folder, from tree: [Folder]) -> [Folder]
}
