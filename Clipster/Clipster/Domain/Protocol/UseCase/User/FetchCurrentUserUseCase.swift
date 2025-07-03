protocol FetchCurrentUserUseCase {
    func execute() async -> Result<User, Error>
}
