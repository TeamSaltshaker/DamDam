protocol SocialLoginService {
    func login() async -> Result<String, Error>
}
