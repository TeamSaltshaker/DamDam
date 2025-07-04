import Foundation

struct ClipDTO: Codable {
    var id: UUID
    var parentID: UUID?
    var urlString: String
    var title: String
    var memo: String
    var thumbnailImageURLString: String?
    var createdAt: Date
    var lastVisitedAt: Date?
    var editedAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    var userID: UUID?
}
