import Foundation

struct Clip {
    let id: UUID
    let folderID: UUID
    let urlMetadata: URLMetadata
    let memo: String
    let lastVisitedAt: Date?
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
}
