final class DefaultCanSelectFolderUseCase: CanSelectFolderUseCase {
    func execute(selectedFolder: Folder?, isClip: Bool) -> Bool {
        isClip ? selectedFolder != nil : true
    }
}
