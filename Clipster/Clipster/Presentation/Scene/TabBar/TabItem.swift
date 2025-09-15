import UIKit

enum TabItem: Int, CaseIterable {
    case home
    case search
    case myPage

    static var defaultTab: TabItem = .home
}

extension TabItem {
    var selectedImage: UIImage {
        switch self {
        case .home:
            return .homeSelected
        case .search:
            return .searchSelected
        case .myPage:
            return .userSelected
        }
    }

    var unselectedImage: UIImage {
        switch self {
        case .home:
            return .home
        case .search:
            return .search
        case .myPage:
            return .user
        }
    }
}
