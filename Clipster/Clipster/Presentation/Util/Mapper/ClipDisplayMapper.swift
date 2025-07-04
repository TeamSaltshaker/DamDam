import Foundation

struct ClipDisplayMapper {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()

    static func map(_ clip: Clip) -> ClipDisplay {
        let urlMetadataDisplay = URLMetadataDisplay(
            url: clip.url,
            title: clip.title.isEmpty ? " " : clip.title,
            description: clip.subtitle.isEmpty ? " " : clip.subtitle,
            thumbnailImageURL: clip.thumbnailImageURL,
            screenshotImageData: clip.screenshotData
        )

        let recentVisitedDate = formatDateString(prefix: "최근 방문한 날짜:", date: clip.lastVisitedAt, fallback: "방문 이력 없음")
        let recentEditedDate = formatDateString(prefix: "최근 수정한 날짜:", date: clip.updatedAt)
        let createdDate = formatDateString(prefix: "생성된 날짜:", date: clip.createdAt)
        let isShowSubTitle = !clip.subtitle.contains("알 수 없음") && clip.memo.isEmpty

        return ClipDisplay(
            id: clip.id,
            urlMetadata: urlMetadataDisplay,
            subTitle: clip.subtitle,
            memo: clip.memo.isEmpty ? " " : clip.memo,
            isShowSubTitle: isShowSubTitle,
            memoLimit: "\(clip.memo.count) / 100",
            isVisited: clip.lastVisitedAt != nil,
            recentVisitedDate: recentVisitedDate,
            recentEditedDate: recentEditedDate,
            createdDate: createdDate
        )
    }

    private static func formatDateString(prefix: String, date: Date?, fallback: String = "") -> String {
        if let date {
            let dateString = dateFormatter.string(from: date)
            return "\(prefix) \(dateString)"
        } else {
            return "\(prefix) \(fallback)"
        }
    }
}
