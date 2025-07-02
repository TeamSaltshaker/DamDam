protocol AuthService {
    func loginWithApple(token: String) async -> Result<Void, Error>
}
