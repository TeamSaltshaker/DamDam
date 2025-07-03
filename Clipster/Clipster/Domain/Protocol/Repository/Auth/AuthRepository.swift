import Foundation

protocol AuthRepository {
    func currentUserID() async -> UUID?
    func login(type: LoginType) async -> Result<User, Error>
    func logout() async -> Result<Void, Error>
    func withdraw() async -> Result<Void, Error>
}
