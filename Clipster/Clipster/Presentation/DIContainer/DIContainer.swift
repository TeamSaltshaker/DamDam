import Foundation

protocol DIContainer {
    func makeClipDetailReactor(clip: Clip) -> ClipDetailReactor
    func makeEditClipReactor() -> EditClipReactor
    func makeEditClipReactor(folder: Folder?) -> EditClipReactor
    func makeEditClipReactor(clip: Clip) -> EditClipReactor
    func makeEditFolderReactor(parentFolder: Folder?, folder: Folder?) -> EditFolderReactor
    func makeFolderReactor(folder: Folder) -> FolderReactor
    func makeHomeReactor() -> HomeReactor
    func makeUnvisitedClipListReactor(clips: [Clip]) -> UnvisitedClipListReactor
    func makeFolderSelectorReactorForClip(parentFolder: Folder?) -> FolderSelectorReactor
    func makeFolderSelectorReactorForFolder(parentFolder: Folder?, folder: Folder?) -> FolderSelectorReactor
    func makeSearchReactor() -> SearchReactor
    func makeMyPageReactor() -> MyPageReactor
    func makeDDWebReactor(url: URL) -> DDWebReactor
}
