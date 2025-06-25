import Foundation

struct Clip {
    let id: UUID
    let folderID: UUID
    let url: URL
    let title: String
    let memo: String
    let thumbnailImageURL: URL?
    let screenshotData: Data?
    let createdAt: Date
    let lastVisitedAt: Date?
    let updatedAt: Date
    let deletedAt: Date?
}
