import Foundation

protocol UserService {
    func fetchUser(by id: UUID) async -> User?
}
