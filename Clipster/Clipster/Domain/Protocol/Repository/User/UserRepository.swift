protocol UserRepository {
    func fetchCurrentUser() async -> Result<User, Error>
    func updateNickname(_ nickname: String) async -> Result<User, Error>
}
