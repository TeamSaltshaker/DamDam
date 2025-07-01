import UIKit

enum DropdownItem: Hashable {
    case sort(SortOption)
}

extension DropdownItem {
    var title: String {
        switch self {
        case .sort: "정렬 순서"
        }
    }

    var value: String {
        switch self {
        case .sort(let option): option.displayText
        }
    }

    var image: UIImage {
        switch self {
        case .sort(let option):
            return option.isAscending
            ? .chevronLightUp .withTintColor(.black500)
            : .chevronLightDown.withTintColor(.black500)
        }
    }
}
