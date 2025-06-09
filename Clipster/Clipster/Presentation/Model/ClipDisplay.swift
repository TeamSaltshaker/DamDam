import Foundation

struct ClipDisplay: Hashable {
    let id: UUID
    let urlMetadata: URLMetadataDisplay
    let memo: String
    let createdAt: String
    let isVisited: Bool
}
