import Foundation

actor FolderClipCache {
    private var folderCache = [UUID: Folder]()
    private var clipCache = [UUID: Clip]()

    func folders() -> [Folder] {
        Array(folderCache.values)
    }

    func folder(by id: UUID) -> Folder? {
        folderCache[id]
    }

    func setFolder(_ folder: Folder) {
        folderCache[folder.id] = folder
    }

    func resetAndSetFolders(_ folders: [Folder]) {
        folderCache = Dictionary(uniqueKeysWithValues: folders.map { ($0.id, $0) })
    }

    func clips() -> [Clip] {
        Array(clipCache.values)
    }

    func clip(by id: UUID) -> Clip? {
        clipCache[id]
    }

    func setClip(_ clip: Clip) {
        clipCache[clip.id] = clip
    }

    func resetAndSetClips(_ clips: [Clip]) {
        clipCache = Dictionary(uniqueKeysWithValues: clips.map { ($0.id, $0) })
    }
}
