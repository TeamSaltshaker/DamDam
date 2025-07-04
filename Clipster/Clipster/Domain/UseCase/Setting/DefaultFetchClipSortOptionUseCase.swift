import Foundation

final class DefaultFetchClipSortOptionUseCase: FetchClipSortOptionUseCase {
    private let userDefaults: UserDefaults
    private let key = "clipSortOption"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func execute() async -> Result<ClipSortOption, Error> {
        guard let raw = userDefaults.string(forKey: key),
              let option = convertFromRawString(raw) else {
            return .success(.createdAt(.ascending))
        }

        return .success(option)
    }
}

private extension DefaultFetchClipSortOptionUseCase {
    func convertFromRawString(_ raw: String) -> ClipSortOption? {
        let components = raw.split(separator: "|").map(String.init)
        guard components.count == 2 else { return nil }

        let type = components[0]
        let dirRaw = components[1]

        guard let direction = convertFromRawStringToSortDirection(dirRaw) else { return nil }

        switch type {
        case "title": return .title(direction)
        case "lastVisitedAt": return .lastVisitedAt(direction)
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
