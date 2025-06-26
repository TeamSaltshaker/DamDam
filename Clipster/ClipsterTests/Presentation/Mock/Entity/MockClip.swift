import Foundation
@testable import Clipster

enum MockClip {
    static let unvisitedClips: [Clip] = [
        Clip(
            id: UUID(),
            folderID: UUID(),
            url: URL(string: "https://example.com/1")!,
            title: "Example Title 1",
            memo: "Clip 1",
            thumbnailImageURL: URL(string: "https://example.com/thumb1.png"),
            screenshotData: nil,
            createdAt: Date(),
            lastVisitedAt: nil,
            updatedAt: Date(),
            deletedAt: nil
        ),
        Clip(
            id: UUID(),
            folderID: UUID(),
            url: URL(string: "https://example.com/2")!,
            title: "Example Title 2",
            memo: "Clip 2",
            thumbnailImageURL: URL(string: "https://example.com/thumb2.png"),
            screenshotData: nil,
            createdAt: Date(),
            lastVisitedAt: Date(),
            updatedAt: Date(),
            deletedAt: nil
        ),
        Clip(
            id: UUID(),
            folderID: UUID(),
            url: URL(string: "https://example.com/3")!,
            title: "Example Title 3",
            memo: "Clip 3",
            thumbnailImageURL: nil,
            screenshotData: nil,
            createdAt: Date(),
            lastVisitedAt: nil,
            updatedAt: Date(),
            deletedAt: nil
        )
    ]
}
