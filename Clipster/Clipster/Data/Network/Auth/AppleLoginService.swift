import AuthenticationServices

final class AppleLoginService: NSObject, SocialLoginService {
    private var continuation: CheckedContinuation<Result<String, Error>, Never>?
    private var provider: ASAuthorizationControllerPresentationContextProviding?

    func login(presentationAnchor: ASPresentationAnchor) async -> Result<String, Error> {
        let provider = await StaticPresentationProvider(anchor: presentationAnchor)
        self.provider = provider

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.email, .fullName]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = provider
        controller.performRequests()

        return await withCheckedContinuation { continuation in
            self.continuation = continuation
        }
    }
}

extension AppleLoginService: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
           let tokenData = credential.identityToken,
           let token = String(data: tokenData, encoding: .utf8) {
            continuation?.resume(returning: .success(token))
        } else {
            continuation?.resume(returning: .failure(LoginError.invalidToken))
        }
        continuation = nil
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        continuation?.resume(returning: .failure(error))
        continuation = nil
    }
}

private final class StaticPresentationProvider: NSObject, ASAuthorizationControllerPresentationContextProviding {
    let anchor: ASPresentationAnchor

    init(anchor: ASPresentationAnchor) {
        self.anchor = anchor
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        anchor
    }
}
