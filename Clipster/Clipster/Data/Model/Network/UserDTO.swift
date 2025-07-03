import Foundation

struct UserDTO: Codable {
    var id: UUID
    var nickname: String
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
}
