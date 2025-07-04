import Foundation

struct FolderDisplayMapper {
    static func map(_ folder: Folder) -> FolderDisplay {
        let totalCount = folder.folders.count + folder.clips.count

        return FolderDisplay(
            id: folder.id,
            title: folder.title,
            depth: folder.depth,
            itemCount: "\(totalCount)개의 항목",
            folderCount: "\(folder.folders.count)",
            isExpanded: false,
            isHighlighted: false,
            hasSubfolders: !folder.folders.isEmpty
        )
    }

    static func map(_ folder: Folder, isExpanded: Bool, isHighlighted: Bool) -> FolderDisplay {
        let totalCount = folder.folders.count + folder.clips.count

        return FolderDisplay(
            id: folder.id,
            title: folder.title,
            depth: folder.depth,
            itemCount: "\(totalCount)개의 항목",
            folderCount: "\(folder.folders.count)",
            isExpanded: isExpanded,
            isHighlighted: isHighlighted,
            hasSubfolders: !folder.folders.isEmpty
        )
    }
}
