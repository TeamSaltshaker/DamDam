enum DetailItem: Hashable {
    case theme(ThemeOption)
    case savePath(SavePathOption)
}

extension DetailItem {
    var title: String {
        switch self {
        case .theme: "테마"
        case .savePath: "저장 경로 보기"
        }
    }

    var value: String {
        switch self {
        case .theme(let option): option.displayText
        case .savePath(let option): option.displayText
        }
    }
}
