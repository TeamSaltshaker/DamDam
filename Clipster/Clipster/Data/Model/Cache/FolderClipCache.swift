import Foundation

actor FolderClipCache {
    private var folderCache = [UUID: Folder]()
    private var clipCache = [UUID: Clip]()

    var isFoldersInitialized = false
    var isClipsInitialized = false

    var isInitialized: Bool {
        isFoldersInitialized && isClipsInitialized
    }

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
        isFoldersInitialized = true
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
        isClipsInitialized = true
    }

    func reset() {
        folderCache.removeAll()
        clipCache.removeAll()
        isFoldersInitialized = false
        isClipsInitialized = false
    }
}
