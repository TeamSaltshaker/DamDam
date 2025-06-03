import Foundation

struct Folder {
    let id: UUID
    let parentFolderID: UUID?
    let title: String
    let folders: [Folder]
    let clips: [Clip]
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
}
