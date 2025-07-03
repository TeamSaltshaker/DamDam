final class DefaultUpdateNicknameUseCase: UpdateNicknameUseCase {
    private let userService: UserService

    init(userService: UserService) {
        self.userService = userService
    }

    func execute(nickname: String) async -> Result<User, Error> {
        await userService.updateNickname(nickname)
            .mapError { _ in DomainError.unknownError }
    }
}
