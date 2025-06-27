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

    static let someFolder: Folder = {
        let folderID = UUID()
        let now = Date.now

        return Folder(
            id: folderID,
            parentFolderID: nil,
            title: "Learning iOS",
            depth: 0,
            folders: [
                Folder(
                    id: UUID(),
                    parentFolderID: folderID,
                    title: "UIKit",
                    depth: 1,
                    folders: [],
                    clips: [],
                    createdAt: now,
                    updatedAt: now,
                    deletedAt: nil,
                ),
                Folder(
                    id: UUID(),
                    parentFolderID: folderID,
                    title: "SwiftUI",
                    depth: 1,
                    folders: [],
                    clips: [],
                    createdAt: now,
                    updatedAt: now,
                    deletedAt: nil,
                )
            ],
            clips: [
                Clip(
                    id: UUID(),
                    folderID: folderID,
                    url: URL(string: "https://docs.swift.org/swift-book/documentation/the-swift-programming-language/thebasics/")!,
                    title: "The Basics | Documentation",
                    subtitle: "Work with common kinds of data and write basic syntax.",
                    memo: "Swift 공식 문서",
                    thumbnailImageURL: URL(string: "https://picsum.photos/200"),
                    screenshotData: nil,
                    createdAt: now,
                    lastVisitedAt: nil,
                    updatedAt: now,
                    deletedAt: nil,
                ),
                Clip(
                    id: UUID(),
                    folderID: folderID,
                    url: URL(string: "https://www.swift.org/documentation/api-design-guidelines/")!,
                    title: "Swift.org - API Design Guidelines",
                    subtitle: "Swift is a general-purpose programming language built using a modern approach to safety, performance, and software design patterns.",
                    memo: "Swift의 코드 컨벤션은 이 사이트를 참고하기",
                    thumbnailImageURL: URL(string: "https://picsum.photos/200"),
                    screenshotData: nil,
                    createdAt: now,
                    lastVisitedAt: nil,
                    updatedAt: now,
                    deletedAt: nil
                )
            ],
            createdAt: now,
            updatedAt: now,
            deletedAt: nil,
        )
    }()
}
