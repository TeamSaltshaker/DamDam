import AuthenticationServices

protocol LoginUseCase {
    func execute(type: LoginType, anchor: ASPresentationAnchor) async -> Result<String, Error>
}
