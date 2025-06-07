import Foundation

struct ClipDisplayMapper {
    static func map(_ clip: Clip) -> ClipDisplay {
        let urlMetadataDisplay = URLMetadataDisplay(
            url: clip.urlMetadata.url,
            title: clip.urlMetadata.title,
            thumbnailImageURL: clip.urlMetadata.thumbnailImageURL
        )

        let createdAt = formatDate(clip.createdAt)
        let lastVisitedAt = clip.lastVisitedAt.map(formatDate) ?? "방문 기록 없음"

        return ClipDisplay(
            urlMetadata: urlMetadataDisplay,
            memo: clip.memo,
            lastVisitedAt: lastVisitedAt,
            createdAt: createdAt
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
