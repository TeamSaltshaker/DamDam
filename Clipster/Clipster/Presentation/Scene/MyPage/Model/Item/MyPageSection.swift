enum MyPageSection: Hashable {
    case login(String)
    case profile
    case systemSettings
    case notificationSettings
    case trash
    case support
    case etc
}

extension MyPageSection {
    var title: String {
        switch self {
        case .login(let title): title
        case .profile: "개인정보수정"
        case .systemSettings: "시스템 설정"
        case .notificationSettings: ""
        case .trash: ""
        case .support: ""
        case .etc: ""
        }
    }
}
