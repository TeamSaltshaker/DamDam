final class DefaultLoginUseCase: LoginUseCase {
    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    func execute(type: LoginType) async -> Result<User, Error> {
        await authRepository.login(type: type)
    }
}
