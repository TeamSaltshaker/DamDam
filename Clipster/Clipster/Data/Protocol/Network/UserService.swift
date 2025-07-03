import Foundation

protocol UserService {
    func fetchUser(by id: UUID) async -> Result<User, Error>
    func insertUser(with id: UUID) async -> Result<Void, Error>
    func updateUser(_ dto: UserDTO) async -> Result<Void, Error>
}
