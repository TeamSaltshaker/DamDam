import Foundation

protocol UserService {
    func fetchUser(by id: UUID) async -> Result<UserDTO?, Error>
    func insertUser(with id: UUID) async -> Result<UserDTO, Error>
    func updateNickname(_ nickname: String) async -> Result<UserDTO, Error>
}
