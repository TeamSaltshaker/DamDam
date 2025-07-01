enum SortOption: Int, CaseIterable, Hashable {
    case createdAsc, createdDesc
    case visitedAsc, visitedDesc
    case titleAsc, titleDesc
    case editedAsc, editedDesc
}

extension SortOption {
    var displayText: String {
        switch self {
        case .createdAsc, .createdDesc: "생성일"
        case .visitedAsc, .visitedDesc: "방문일"
        case .titleAsc, .titleDesc: "제목"
        case .editedAsc, .editedDesc: "편집일"
        }
    }

    var isAscending: Bool {
        switch self {
        case .createdAsc, .visitedAsc, .titleAsc, .editedAsc:
            return true
        default:
            return false
        }
    }
}
