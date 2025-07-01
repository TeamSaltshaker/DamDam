import UIKit

enum DropdownItem: Hashable {
    case folderSort(FolderSortOption)
    case clipSort(ClipSortOption)
}

extension DropdownItem {
    var title: String {
        switch self {
        case .folderSort: "폴더 정렬 순서"
        case .clipSort: "클립 정렬 순서"
        }
    }

    var value: String {
        switch self {
        case .folderSort(let option):
            option.displayText
        case .clipSort(let option):
            option.displayText
        }
    }

    var image: UIImage {
        switch self {
        case .folderSort(let option):
            option.direction.icon
        case .clipSort(let option):
            option.direction.icon
        }
    }
}
