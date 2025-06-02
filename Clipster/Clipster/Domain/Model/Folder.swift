import Foundation

struct Folder {
    let id: UUID
    let parentFolderID: UUID?
    let title: String
    let folders: [Folder]
    let clips: [Clip]
    let createdAt: Date
    let udpatedAt: Date
    let deletedAt: Date?
}
