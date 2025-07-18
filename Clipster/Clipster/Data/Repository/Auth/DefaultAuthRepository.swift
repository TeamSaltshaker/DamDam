import Foundation

final class DefaultAuthRepository: AuthRepository {
    private let socialLoginServices: [LoginType: SocialLoginService]
    private let authService: AuthService
    private let userService: UserService
    private let mapper: DomainMapper

    init(
        socialLoginServices: [LoginType: SocialLoginService],
        authService: AuthService,
        userService: UserService,
        mapper: DomainMapper,
    ) {
        self.socialLoginServices = socialLoginServices
        self.authService = authService
        self.userService = userService
        self.mapper = mapper
    }

    func currentUserID() async -> UUID? {
        authService.currentUserID()
    }

    func login(type: LoginType) async -> Result<User, Error> {
        guard let socialLoginService = socialLoginServices[type] else {
            return .failure(LoginError.unsupportedType)
        }

        do {
            let jwt = try await socialLoginService.login().get()
            let userID = try await authService.login(loginType: type, token: jwt).get()

            if let userDTO = try await userService.fetchUser(by: userID).get() {
                let user = mapper.user(from: userDTO)
                print("\(Self.self): ✅ Login Success. id: \(user.id), nickname: \(user.nickname)")
                return .success(user)
            } else {
                let newUserDTO = try await userService.insertUser(with: userID).get()
                let newUser = mapper.user(from: newUserDTO)
                print("\(Self.self): ✅ SignUp and Login Success. id: \(newUser.id), nickname: \(newUser.nickname)")
                return .success(newUser)
            }
        } catch {
            print("\(Self.self): ❌ Login Failed. \(error.localizedDescription)")
            return .failure(error)
        }
    }

    func logout() async -> Result<Void, Error> {
        await authService.logout()
    }

    func withdraw() async -> Result<Void, Error> {
        await authService.withdraw()
    }
}
