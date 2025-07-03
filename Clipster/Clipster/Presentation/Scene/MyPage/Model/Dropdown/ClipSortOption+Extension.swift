extension ClipSortOption {
    static var allCases: [ClipSortOption] = [
        .createdAt(.descending),
        .lastVisitedAt(.descending),
        .title(.descending),
        .updatedAt(.descending)
    ]

    var displayText: String {
        switch self {
        case .title: "제목"
        case .lastVisitedAt: "방문일"
        case .createdAt: "생성일"
        case .updatedAt: "편집일"
        }
    }

    var isAscending: Bool {
        switch self {
        case .title(let dir),
             .lastVisitedAt(let dir),
             .createdAt(let dir),
             .updatedAt(let dir):
            return dir == .ascending
        }
    }

    var direction: SortDirection {
        switch self {
        case .title(let dir),
             .lastVisitedAt(let dir),
             .createdAt(let dir),
             .updatedAt(let dir):
            return dir
        }
    }
}
