final class DefaultFilterSubfoldersUseCase: FilterSubfoldersUseCase {
    func execute(topLevelFolders: [Folder], currentPath: [Folder], folder: Folder?) -> [Folder] {
        let parentFolder = currentPath.last
        let subfolder = parentFolder?.folders ?? topLevelFolders
        return subfolder.filter { $0.id != folder?.id }
    }
}
