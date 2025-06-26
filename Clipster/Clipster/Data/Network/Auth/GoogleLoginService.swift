import GoogleSignIn
import UIKit

final class GoogleLoginService: SocialLoginService {
    @MainActor
    func login() async -> Result<String, Error> {
        do {
            let presentingVC = findCurrentPresentedViewController()
            guard let vc = presentingVC else {
                return .failure(LoginError.invalidRootVC)
            }

            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: vc)

            guard let token = result.user.idToken?.tokenString else {
                return .failure(LoginError.invalidToken)
            }
            return .success(token)
        } catch {
            return .failure(error)
        }
    }
}

extension GoogleLoginService {
    private func findCurrentPresentedViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController
        else {
            return nil
        }
        return topViewController(from: root)
    }

    private func topViewController(from vc: UIViewController) -> UIViewController {
        if let presented = vc.presentedViewController {
            return topViewController(from: presented)
        } else if let nav = vc as? UINavigationController {
            return topViewController(from: nav.visibleViewController ?? nav)
        } else if let tab = vc as? UITabBarController {
            return topViewController(from: tab.selectedViewController ?? tab)
        } else {
            return vc
        }
    }
}
