import Foundation
@testable import Clipster

enum MockFolder {
    static let rootFolders: [Folder] = {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!

        return [
            Folder(
                id: UUID(),
                parentFolderID: nil,
                title: "Today Folder",
                depth: 0,
                folders: [],
                clips: [],
                createdAt: today,
                updatedAt: today,
                deletedAt: nil
            ),
            Folder(
                id: UUID(),
                parentFolderID: nil,
                title: "Yesterday Folder",
                depth: 0,
                folders: [],
                clips: [],
                createdAt: yesterday,
                updatedAt: yesterday,
                deletedAt: nil
            )
        ]
    }()
}
