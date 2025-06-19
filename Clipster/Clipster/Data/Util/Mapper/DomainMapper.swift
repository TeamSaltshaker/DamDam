import Foundation

struct DomainMapper {
    func folder(from entity: FolderEntity) -> Folder? {
        guard let folders = entity.folders?.compactMap(folder),
              let clips = entity.clips?.compactMap(clip) else {
            return nil
        }

        return Folder(
            id: entity.id,
            parentFolderID: entity.parentFolder?.id,
            title: entity.title,
            depth: Int(entity.depth),
            folders: folders,
            clips: clips,
            createdAt: entity.createdAt,
            updatedAt: entity.updatedAt,
            deletedAt: entity.deletedAt,
        )
    }

    func clip(from entity: ClipEntity) -> Clip? {
        guard let folderID = entity.folder?.id,
              let url = URL(string: entity.urlString)
        else { return nil }

        return Clip(
            id: entity.id,
            folderID: folderID,
            url: url,
            title: entity.title,
            memo: entity.memo,
            thumbnailImageURL: URL(string: entity.thumbnailImageURLString ?? ""),
            screenshotData: entity.screenshotData,
            lastVisitedAt: entity.lastVisitedAt,
            createdAt: entity.createdAt,
            updatedAt: entity.updatedAt,
            deletedAt: entity.deletedAt,
        )
    }
}
