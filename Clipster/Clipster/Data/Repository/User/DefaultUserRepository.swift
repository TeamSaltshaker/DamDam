final class DefaultUserRepository: UserRepository {
    private let authService: AuthService
    private let userService: UserService
    private let mapper: DomainMapper

    init(
        authService: AuthService,
        userService: UserService,
        mapper: DomainMapper,
    ) {
        self.authService = authService
        self.userService = userService
        self.mapper = mapper
    }

    func updateNickname(_ nickname: String) async -> Result<User, Error> {
        await userService.updateNickname(nickname)
            .map { mapper.user(from: $0) }
    }
}
