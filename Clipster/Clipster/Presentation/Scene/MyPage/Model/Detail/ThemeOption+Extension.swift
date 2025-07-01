extension ThemeOption {
    var displayText: String {
        switch self {
        case .system: "시스템 기본"
        case .light: "라이트"
        case .dark: "다크"
        }
    }
}
