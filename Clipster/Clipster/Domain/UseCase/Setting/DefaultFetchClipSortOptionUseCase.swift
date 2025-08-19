import Foundation

final class DefaultFetchClipSortOptionUseCase: FetchClipSortOptionUseCase {
    private let userDefaultsRepository: UserDefaultsRepository

    init(userDefaultsRepository: UserDefaultsRepository) {
        self.userDefaultsRepository = userDefaultsRepository
    }

    func execute() async -> Result<ClipSortOption, Error> {
        guard let raw = userDefaultsRepository.clipSortOption(),
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
