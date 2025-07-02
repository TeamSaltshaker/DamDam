import Foundation

final class DefaultSaveClipSortUseCase: SaveClipSortUseCase {
    private let userDefaults: UserDefaults
    private let key = "clip_sort_option"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func execute(_ option: ClipSortOption) async -> Result<Void, Error> {
        let raw = convertToRawString(from: option)
        userDefaults.set(raw, forKey: key)
        return .success(())
    }
}

private extension DefaultSaveClipSortUseCase {
    func convertToRawString(from option: ClipSortOption) -> String {
        switch option {
        case .title(let dir): return "title|\(convertToRawString(from: dir))"
        case .lastVisitedAt(let dir): return "lastVisitedAt|\(convertToRawString(from: dir))"
        case .createdAt(let dir): return "createdAt|\(convertToRawString(from: dir))"
        case .updatedAt(let dir): return "updatedAt|\(convertToRawString(from: dir))"
        }
    }

    func convertToRawString(from direction: SortDirection) -> String {
        switch direction {
        case .ascending: return "ascending"
        case .descending: return "descending"
        }
    }
}
