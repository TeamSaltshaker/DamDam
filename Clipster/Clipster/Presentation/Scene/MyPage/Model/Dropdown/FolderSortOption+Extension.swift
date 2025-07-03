extension FolderSortOption {
    static var allCases: [FolderSortOption] = [
        .createdAt(.descending),
        .title(.descending),
        .updatedAt(.descending)
    ]

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

extension FolderSortOption: SortableOption {
    func toggled() -> FolderSortOption {
        switch self {
        case .title(let dir):
            return .title(dir == .ascending ? .descending : .ascending)
        case .createdAt(let dir):
            return .createdAt(dir == .ascending ? .descending : .ascending)
        case .updatedAt(let dir):
            return .updatedAt(dir == .ascending ? .descending : .ascending)
        }
    }

    func isSameSortBasis(as other: FolderSortOption) -> Bool {
        switch (self, other) {
        case (.title, .title),
             (.createdAt, .createdAt),
             (.updatedAt, .updatedAt):
            return true
        default:
            return false
        }
    }
}
