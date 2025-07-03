final class DefaultCheckLoginStatusUseCase: CheckLoginStatusUseCase {
    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    func execute() async -> Bool {
        await authRepository.currentUserID() != nil
    }
}
