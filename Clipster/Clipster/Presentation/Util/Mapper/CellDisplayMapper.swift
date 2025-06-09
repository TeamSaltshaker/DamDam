import Foundation

struct CellDisplayMapper {
    func folderCellDisplay(from folder: Folder) -> FolderCellDisplay {
        FolderCellDisplay(
            id: folder.id,
            title: folder.title,
            itemCount: folder.folders.count + folder.clips.count
        )
    }
}
