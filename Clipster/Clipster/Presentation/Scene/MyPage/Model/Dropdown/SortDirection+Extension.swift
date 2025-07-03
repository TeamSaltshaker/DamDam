import UIKit

extension SortDirection {
    var icon: UIImage {
        switch self {
        case .ascending:
            return .chevronLightUp.withTintColor(.black500)
        case .descending:
            return .chevronLightDown.withTintColor(.black500)
        }
    }
}
