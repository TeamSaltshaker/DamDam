final class DefaultFetchCurrentUserUseCase: FetchCurrentUserUseCase {
    private let userRepository: UserRepository

    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    func execute() async -> Result<User, Error> {
        await userRepository.fetchCurrentUser()
    }
}
