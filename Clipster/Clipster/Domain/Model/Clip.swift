import Foundation

struct Clip {
    let id: UUID
    let folderID: UUID
    let urlMetadata: URLMetadata
    let memo: String
    let isVisited: Bool
    let createdAt: Date
    let udpatedAt: Date
    let deletedAt: Date?
}
