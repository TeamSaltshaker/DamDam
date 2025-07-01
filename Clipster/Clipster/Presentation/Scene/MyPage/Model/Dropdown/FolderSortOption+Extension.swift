extension FolderSortOption {
    var displayText: String {
        switch self {
        case .title: "제목"
        case .createdAt: "생성일"
        case .updatedAt: "편집일"
        }
    }

    var isAscending: Bool {
        switch self {
        case .title(let dir),
             .createdAt(let dir),
             .updatedAt(let dir):
            return dir == .ascending
        }
    }

    var direction: SortDirection {
        switch self {
        case .title(let dir),
             .createdAt(let dir),
             .updatedAt(let dir):
            return dir
        }
    }
}
