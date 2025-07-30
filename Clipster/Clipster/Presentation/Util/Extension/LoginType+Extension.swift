import UIKit

extension LoginType {
    var title: String {
        switch self {
        case .apple: "Apple로 로그인"
        case .google: "Google로 로그인"
        }
    }

    var icon: UIImage {
        switch self {
        case .apple: .appleIcon
        case .google: .googleIcon
        }
    }
}
