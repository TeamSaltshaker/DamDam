import Foundation

struct FolderDisplay: Hashable {
    let id: UUID
    let title: String
    let depth: Int
    let itemCount: String
    let folderCount: String
    let isExpanded: Bool
    let isHighlighted: Bool
    let hasSubfolders: Bool
}
