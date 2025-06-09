import Foundation

struct CellDisplayMapper {
    func folderCellDisplay(from folder: Folder) -> FolderCellDisplay {
        FolderCellDisplay(
            id: folder.id,
            title: folder.title,
            itemCount: folder.folders.count + folder.clips.count
        )
    }

    func clipCellDisplay(from clip: Clip) -> ClipCellDisplay {
        ClipCellDisplay(
            thumbnailImageURL: clip.urlMetadata.thumbnailImageURL,
            title: clip.urlMetadata.title,
            memo: clip.memo,
            isVisited: clip.lastVisitedAt != nil
        )
    }
}
