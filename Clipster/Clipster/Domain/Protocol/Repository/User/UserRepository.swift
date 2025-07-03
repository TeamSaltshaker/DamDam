protocol UserRepository {
    func updateNickname(_ nickname: String) async -> Result<User, Error>
}
