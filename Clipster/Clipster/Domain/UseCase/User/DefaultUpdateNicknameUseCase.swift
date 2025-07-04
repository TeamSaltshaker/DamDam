final class DefaultUpdateNicknameUseCase: UpdateNicknameUseCase {
    private let userRepository: UserRepository

    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    func execute(nickname: String) async -> Result<User, Error> {
        await userRepository.updateNickname(nickname)
    }
}
