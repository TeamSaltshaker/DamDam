struct FolderDisplayMapper {
    static func map(_ folder: Folder) -> FolderDisplay {
        let totalCount = folder.folders.count + folder.clips.count

        return FolderDisplay(
            id: folder.id,
            title: folder.title,
            itemCount: "\(totalCount)개의 항목"
        )
    }
}
