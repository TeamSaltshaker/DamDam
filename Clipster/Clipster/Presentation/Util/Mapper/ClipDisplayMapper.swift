import Foundation

struct ClipDisplayMapper {
    static func map(_ clip: Clip) -> ClipDisplay {
        let urlMetadataDisplay = URLMetadataDisplay(
            url: clip.urlMetadata.url,
            title: clip.urlMetadata.title.isEmpty ? " " : clip.urlMetadata.title,
            thumbnailImageURL: clip.urlMetadata.thumbnailImageURL,
            screenshotImageData: clip.urlMetadata.screenshotData
        )

        return ClipDisplay(
            id: clip.id,
            urlMetadata: urlMetadataDisplay,
            memo: clip.memo.isEmpty ? " " : clip.memo,
            memoLimit: "\(clip.memo.count) / 100",
            isVisited: clip.lastVisitedAt != nil
        )
    }
}
