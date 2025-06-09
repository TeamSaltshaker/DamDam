import Foundation

struct ClipDisplayMapper {
    static func map(_ clip: Clip) -> ClipDisplay {
        let urlMetadataDisplay = URLMetadataDisplay(
            url: clip.urlMetadata.url,
            title: clip.urlMetadata.title,
            thumbnailImageURL: clip.urlMetadata.thumbnailImageURL
        )

        return ClipDisplay(
            id: clip.id,
            urlMetadata: urlMetadataDisplay,
            memo: clip.memo,
            createdAt: formatDate(clip.createdAt),
            isVisited: clip.lastVisitedAt != nil
        )
    }

    private static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}
