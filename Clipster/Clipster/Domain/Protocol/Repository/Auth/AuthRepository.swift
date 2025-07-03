protocol AuthRepository {
    func login(type: LoginType) async -> Result<User, Error>
}
