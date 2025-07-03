protocol LoginUseCase {
    func execute(type: LoginType) async -> Result<User, Error>
}
