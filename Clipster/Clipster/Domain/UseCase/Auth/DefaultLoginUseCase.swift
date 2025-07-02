final class DefaultLoginUseCase: LoginUseCase {
    private let loginServices: [LoginType: SocialLoginService]
    private let authService: AuthService

    init(
        loginServices: [LoginType: SocialLoginService],
        authService: AuthService
    ) {
        self.loginServices = loginServices
        self.authService = authService
    }

    func execute(type: LoginType) async -> Result<String, Error> {
        guard let service = loginServices[type] else {
            return .failure(LoginError.unsupportedType)
        }

        let result = await service.login()

        switch result {
        case .success(let token):
            await authService.loginWithApple(token: token)
            return .success("")
        case .failure(let error):
            return .failure(error)
        }
    }
}
