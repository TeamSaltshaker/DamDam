protocol UpdateNicknameUseCase {
    func execute(nickname: String) async -> Result<User, Error>
}
