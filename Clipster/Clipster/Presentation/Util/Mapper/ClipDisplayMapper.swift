import Foundation

struct ClipDisplayMapper {
    static func map(_ clip: Clip) -> ClipDisplay {
        let urlMetadataDisplay = URLMetadataDisplay(
            url: clip.url,
            title: clip.title.isEmpty ? " " : clip.title,
            description: clip.description.isEmpty ? " " : clip.description,
            thumbnailImageURL: clip.thumbnailImageURL,
            screenshotImageData: clip.screenshotData
        )

        return ClipDisplay(
            id: clip.id,
            urlMetadata: urlMetadataDisplay,
            memo: clip.memo.isEmpty ? " " : clip.memo,
            memoLimit: "\(clip.memo.count) / 100",
            isVisited: clip.lastVisitedAt != nil,
        )
    }
}
