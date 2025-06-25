import AuthenticationServices

protocol SocialLoginService {
    func login(presentationAnchor: ASPresentationAnchor) async -> Result<String, Error>
}
