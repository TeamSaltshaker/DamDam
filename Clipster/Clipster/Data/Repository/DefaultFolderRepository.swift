import Foundation

final class DefaultFolderRepository: FolderRepository {
    private let storage: FolderStorage

    init(storage: FolderStorage) {
        self.storage = storage
    }

    func fetchFolder(by id: UUID) -> Result<Folder, DomainError> {
        storage.fetchFolder(by: id)
            .mapError { _ in .unknownError }
            .flatMap { entity in
                guard let folder = toDomain(from: entity) else {
                    return .failure(.unknownError)
                }
                return .success(folder)
            }
    }

    func fetchTopLevelFolders() -> Result<[Folder], DomainError> {
        storage.fetchTopLevelFolders()
            .mapError { _ in .unknownError }
            .flatMap { entities in
                let folders = entities.compactMap(toDomain)
                return .success(folders)
            }
    }

    func insertFolder(_ folder: Folder) -> Result<Void, DomainError> {
        storage.insertFolder(folder)
            .mapError { _ in .unknownError }
    }

    func updateFolder(_ folder: Folder) -> Result<Void, DomainError> {
        storage.updateFolder(folder)
            .mapError { _ in .unknownError }
    }

    func deleteFolder(_ folder: Folder) -> Result<Void, DomainError> {
        storage.deleteFolder(folder)
            .mapError { _ in .unknownError }
    }

    private func toDomain(from entity: FolderEntity) -> Folder? {
        guard let folders = entity.folders?.compactMap(toDomain),
              let clips = entity.clips?.compactMap(toDomain) else {
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

    private func toDomain(from entity: ClipEntity) -> Clip? {
        guard let folderID = entity.folder?.id,
              let urlMetadataEntity = entity.urlMetadata,
              let urlMetadata = toDomain(from: urlMetadataEntity) else {
            return nil
        }

        return Clip(
            id: entity.id,
            folderID: folderID,
            urlMetadata: urlMetadata,
            memo: entity.memo,
            lastVisitedAt: entity.lastVisitedAt,
            createdAt: entity.createdAt,
            updatedAt: entity.updatedAt,
            deletedAt: entity.deletedAt,
        )
    }

    private func toDomain(from entity: URLMetadataEntity) -> URLMetadata? {
        guard let url = URL(string: entity.urlString),
              let thumbnailImageURL = URL(string: entity.thumbnailImageURLString) else {
            return nil
        }

        return URLMetadata(
            url: url,
            title: entity.title,
            thumbnailImageURL: thumbnailImageURL,
            createdAt: entity.createdAt,
            updatedAt: entity.updatedAt,
            deletedAt: entity.deletedAt,
        )
    }
}
