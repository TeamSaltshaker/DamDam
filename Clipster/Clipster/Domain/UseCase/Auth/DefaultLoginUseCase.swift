final class DefaultLoginUseCase: LoginUseCase {
    private let socialLoginServices: [LoginType: SocialLoginService]
    private let authService: AuthService
    private let userService: UserService

    init(
        socialLoginServices: [LoginType: SocialLoginService],
        authService: AuthService,
        userService: UserService,
    ) {
        self.socialLoginServices = socialLoginServices
        self.authService = authService
        self.userService = userService
    }

    func execute(type: LoginType) async -> Result<User, Error> {
        guard let socialLoginService = socialLoginServices[type] else {
            return .failure(LoginError.unsupportedType)
        }

        do {
            let jwt = try await socialLoginService.login().get()
            let userID = try await authService.login(loginType: type, token: jwt).get()

            if let user = try await userService.fetchUser(by: userID).get() {
                print("\(Self.self): ✅ Login Success. id: \(user.id), nickname: \(user.nickname)")
                return .success(user)
            } else {
                let newUser = try await userService.insertUser(with: userID).get()
                print("\(Self.self): ✅ SignUp and Login Success. id: \(newUser.id), nickname: \(newUser.nickname)")
                return .success(newUser)
            }
        } catch {
            print("\(Self.self): ❌ Login Failed. \(error.localizedDescription)")
            return .failure(error)
        }
    }
}
