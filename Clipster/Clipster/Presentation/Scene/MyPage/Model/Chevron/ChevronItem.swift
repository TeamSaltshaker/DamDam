enum ChevronItem: Hashable {
    case nicknameEdit
    case notificationSetting
    case trash
    case support
}

extension ChevronItem {
    var title: String {
        switch self {
        case .nicknameEdit: "닉네임 변경"
        case .notificationSetting: "알림 설정"
        case .trash: "휴지통"
        case .support: "고객지원"
        }
    }
}
