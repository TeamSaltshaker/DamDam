final class DefaultLoginUseCase: LoginUseCase {
    private let loginServices: [LoginType: SocialLoginService]

    init(loginServices: [LoginType: SocialLoginService]) {
        self.loginServices = loginServices
    }

    func execute(type: LoginType) async -> Result<String, Error> {
        guard let service = loginServices[type] else {
            return .failure(LoginError.unsupportedType)
        }
        return await service.login()
    }
}
