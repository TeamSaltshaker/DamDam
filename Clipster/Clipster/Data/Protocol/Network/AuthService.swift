import Foundation

protocol AuthService {
    func currentUserID() -> UUID?
    func loginWithApple(token: String) async -> Result<Void, Error>
    func logout() async -> Result<Void, Error>
    func withdraw() async -> Result<Void, Error>
}
