final class DefaultLogoutUseCase: LogoutUseCase {
    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    func execute() async -> Result<Void, Error> {
        await authRepository.logout()
    }
}
