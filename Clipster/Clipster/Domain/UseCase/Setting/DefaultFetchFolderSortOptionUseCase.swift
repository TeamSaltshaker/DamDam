import Foundation

final class DefaultFetchFolderSortOptionUseCase: FetchFolderSortOptionUseCase {
    private let userDefaults: UserDefaults
    private let key = "folderSortOption"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func execute() async -> Result<FolderSortOption, Error> {
        guard let raw = userDefaults.string(forKey: key),
              let option = convertFromRawString(raw) else {
            return .success(.createdAt(.descending))
        }
        return .success(option)
    }
}

private extension DefaultFetchFolderSortOptionUseCase {
    func convertFromRawString(_ raw: String) -> FolderSortOption? {
        let components = raw.split(separator: "|").map(String.init)
        guard components.count == 2 else { return nil }

        let type = components[0]
        let dirRaw = components[1]

        guard let direction = convertFromRawStringToSortDirection(dirRaw) else { return nil }

        switch type {
        case "title": return .title(direction)
        case "createdAt": return .createdAt(direction)
        case "updatedAt": return .updatedAt(direction)
        default: return nil
        }
    }

    func convertFromRawStringToSortDirection(_ raw: String) -> SortDirection? {
        switch raw {
        case "ascending": return .ascending
        case "descending": return .descending
        default: return nil
        }
    }
}
