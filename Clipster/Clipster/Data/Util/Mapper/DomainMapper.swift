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
              let urlMetadataEntity = entity.urlMetadata,
              let url = URL(string: urlMetadataEntity.urlString) else {
            return nil
        }

        return Clip(
            id: entity.id,
            folderID: folderID,
            url: url,
            title: urlMetadataEntity.title,
            memo: entity.memo,
            thumbnailImageURL: URL(string: urlMetadataEntity.thumbnailImageURLString ?? ""),
            screenshotData: urlMetadataEntity.screenshotData,
            createdAt: entity.createdAt,
            lastVisitedAt: entity.lastVisitedAt,
            updatedAt: entity.updatedAt,
            deletedAt: entity.deletedAt,
        )
    }
}
