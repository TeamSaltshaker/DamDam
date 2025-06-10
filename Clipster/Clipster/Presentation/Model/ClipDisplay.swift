import Foundation

struct ClipDisplay: Hashable {
    let id: UUID
    let urlMetadata: URLMetadataDisplay
    let memo: String
    let memoLimit: String
    let isVisited: Bool
}
