import Foundation

struct ClipDisplay: Hashable {
    let id: UUID
    let urlMetadata: URLMetadataDisplay
    let subTitle: String
    let memo: String
    let isShowSubTitle: Bool
    let memoLimit: String
    let isVisited: Bool
    let recentVisitedDate: String
    let recentEditedDate: String
    let createdDate: String
}
