final class DefaultUserRepository: UserRepository {
    private let authService: AuthService
    private let userService: UserService

    init(authService: AuthService, userService: UserService) {
        self.authService = authService
        self.userService = userService
    }

    func updateNickname(_ nickname: String) async -> Result<User, any Error> {
        await userService.updateNickname(nickname)
    }
}
