protocol CanSelectFolderUseCase {
    func execute(selectedFolder: Folder?, isClip: Bool) -> Bool
}
