import Foundation

struct ClipCellDisplay: Hashable {
    let id: UUID
    let thumbnailImageURL: URL
    let title: String
    let memo: String
    let isVisited: Bool
}
