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

    func fetchCurrentUser() async -> Result<User, Error> {
        guard let currentUserID = authService.currentUserID() else {
            print("\(Self.self): ❌ Failed to fetch. Not logged in")
            return .failure(AuthError.notLoggedIn)
        }

        do {
            guard let dto = try await userService.fetchUser(by: currentUserID).get() else {
                print("\(Self.self): ❌ Failed to fetch. User entity not found")
                return .failure(AuthError.userNotFound)
            }
            let user = mapper.user(from: dto)
            return .success(user)
        } catch {
            print("\(Self.self): ❌ Failed to fetch. \(error.localizedDescription)")
            return .failure(error)
        }
    }

    func updateNickname(_ nickname: String) async -> Result<User, Error> {
        await userService.updateNickname(nickname)
            .map { mapper.user(from: $0) }
    }
}
