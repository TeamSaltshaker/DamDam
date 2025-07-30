extension SavePathOption {
    var displayText: String {
        switch self {
        case .expand: return "펼치기"
        case .skip: return "넘기기"
        }
    }
}
