import Foundation

struct FolderDTO: Codable {
    var id: UUID
    var parentID: UUID?
    var title: String
    var depth: Int
    var createdAt: Date
    var editedAt: Date
    var updatedAt: Date
    var deletedAt: Date?
}
