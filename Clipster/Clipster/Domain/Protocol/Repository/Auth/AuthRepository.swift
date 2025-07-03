protocol AuthRepository {
    func login(type: LoginType) async -> Result<User, Error>
    func logout() async -> Result<Void, Error>
}
