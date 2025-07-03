import Foundation

protocol UserService {
    func fetchUser(by id: UUID) async -> Result<User?, Error>
    func insertUser(with id: UUID) async -> Result<User, Error>
    func updateNickname(_ nickname: String) async -> Result<User, Error>
}
