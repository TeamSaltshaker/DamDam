import Foundation

final class DefaultClipRepository: ClipRepository {
    private let storage: ClipStorage

    init(storage: ClipStorage) {
        self.storage = storage
    }

    func fetchClip(by id: UUID) -> Result<Clip, DomainError> {
        storage.fetchClip(by: id)
            .mapError { _ in .unknownError }
            .flatMap { entity in
                guard let clip = toDomain(from: entity) else {
                    return .failure(.unknownError)
                }
                return .success(clip)
            }
    }

    func fetchUnvisitedClips() -> Result<[Clip], DomainError> {
        storage.fetchUnvisitedClips()
            .mapError { _ in .unknownError }
            .flatMap { entities in
                let clips = entities.compactMap(toDomain)
                return .success(clips)
            }
    }

    func createClip(_ clip: Clip) -> Result<Void, DomainError> {
        storage.insertClip(clip)
            .mapError { _ in .unknownError }
    }

    func updateClip(_ clip: Clip) -> Result<Void, DomainError> {
        storage.updateClip(clip)
            .mapError { _ in .unknownError }
    }

    func deleteClip(_ clip: Clip) -> Result<Void, DomainError> {
        storage.deleteClip(clip)
            .mapError { _ in .unknownError }
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
