import Foundation
@testable import Clipster

enum MockClip {
    static let unvisitedClips: [Clip] = [
        Clip(
            id: UUID(),
            folderID: UUID(),
            url: URL(string: "https://example.com/1")!,
            title: "Example Title 1",
            subtitle: "Example Subtitle 1",
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
            subtitle: "Example Subtitle 2",
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
            subtitle: "Example Subtitle 3",
            memo: "Clip 3",
            thumbnailImageURL: nil,
            screenshotData: nil,
            createdAt: Date(),
            lastVisitedAt: nil,
            updatedAt: Date(),
            deletedAt: nil
        )
    ]

    static var someClip = Clip(
        id: UUID(),
        folderID: UUID(),
        url: URL(string: "https://example.com/1")!,
        title: "Example Title 1",
        subtitle: "Example Subtitle 1",
        memo: "Clip 1",
        thumbnailImageURL: URL(string: "https://example.com/thumb1.png"),
        screenshotData: nil,
        createdAt: Date(),
        lastVisitedAt: nil,
        updatedAt: Date(),
        deletedAt: nil
    )

    static let unsortedClips: [Clip] = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"

        let date1 = formatter.date(from: "2025/07/01 12:00")!
        let date2 = formatter.date(from: "2025/07/02 12:00")!
        let date3 = formatter.date(from: "2025/07/03 12:00")!

        return [
            Clip(
                id: UUID(),
                folderID: UUID(),
                url: URL(string: "https://example.com/1")!,
                title: "Banana",
                subtitle: "Subtitle 1",
                memo: "Clip 1",
                thumbnailImageURL: URL(string: "https://example.com/thumb1.png"),
                screenshotData: nil,
                createdAt: date2,
                lastVisitedAt: nil,
                updatedAt: date3,
                deletedAt: nil
            ),
            Clip(
                id: UUID(),
                folderID: UUID(),
                url: URL(string: "https://example.com/2")!,
                title: "Apple",
                subtitle: "Subtitle 2",
                memo: "Clip 2",
                thumbnailImageURL: URL(string: "https://example.com/thumb2.png"),
                screenshotData: nil,
                createdAt: date1,
                lastVisitedAt: date3,
                updatedAt: date1,
                deletedAt: nil
            ),
            Clip(
                id: UUID(),
                folderID: UUID(),
                url: URL(string: "https://example.com/3")!,
                title: "Cherry",
                subtitle: "Subtitle 3",
                memo: "Clip 3",
                thumbnailImageURL: nil,
                screenshotData: nil,
                createdAt: date3,
                lastVisitedAt: date2,
                updatedAt: date2,
                deletedAt: nil
            )
        ]
    }()
}
