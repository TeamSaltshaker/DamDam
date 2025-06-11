import UIKit

enum FontWeight: String {
    case extraBold = "ExtraBold"
    case bold = "Bold"
    case semiBold = "SemiBold"
    case medium = "Medium"
    case regular = "Regular"
    case light = "Light"

    var uiFontWeight: UIFont.Weight {
        switch self {
        case .extraBold:
            return .heavy
        case .bold:
            return .bold
        case .semiBold:
            return .semibold
        case .medium:
            return .medium
        case .regular:
            return .regular
        case .light:
            return .light
        }
    }
}

extension UIFont {
    static let pretendardFamilyName = "Pretendard"

    static func pretendard(size: CGFloat, weight: FontWeight) -> UIFont {
        let fontName = "\(pretendardFamilyName)-\(weight.rawValue)"

        guard let font = UIFont(name: fontName, size: size) else {
            return .systemFont(ofSize: size, weight: weight.uiFontWeight)
        }

        return font
    }
}
