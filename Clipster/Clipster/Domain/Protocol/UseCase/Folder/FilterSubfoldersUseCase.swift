protocol FilterSubfoldersUseCase {
    func execute(topLevelFolders: [Folder], currentPath: [Folder], folder: Folder?) -> [Folder]
}
