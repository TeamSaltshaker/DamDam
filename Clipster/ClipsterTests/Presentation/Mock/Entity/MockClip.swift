import Foundation
@testable import Clipster

enum MockClip {
    static let unvisitedClips: [Clip] = [
        Clip(
            id: UUID(),
            folderID: UUID(),
            urlMetadata: MockURLMetadata.urlMetaData,
            memo: "Clip 1",
            lastVisitedAt: nil,
            createdAt: Date(),
            updatedAt: Date(),
            deletedAt: nil
        ),
        Clip(
            id: UUID(),
            folderID: UUID(),
            urlMetadata: MockURLMetadata.urlMetaData,
            memo: "Clip 2",
            lastVisitedAt: Date(),
            createdAt: Date(),
            updatedAt: Date(),
            deletedAt: nil
        ),
        Clip(
            id: UUID(),
            folderID: UUID(),
            urlMetadata: MockURLMetadata.urlMetaData,
            memo: "Clip 2",
            lastVisitedAt: nil,
            createdAt: Date(),
            updatedAt: Date(),
            deletedAt: nil
        )
    ]
}
