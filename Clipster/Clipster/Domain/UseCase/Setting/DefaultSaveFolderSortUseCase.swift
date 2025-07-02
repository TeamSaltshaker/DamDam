import Foundation

final class DefaultSaveFolderSortUseCase: SaveFolderSortUseCase {
    private let userDefaults: UserDefaults
    private let key = "folder_sort_option"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func execute(_ option: FolderSortOption) async -> Result<Void, Error> {
        let raw = convertToRawString(from: option)
        userDefaults.set(raw, forKey: key)
        return .success(())
    }
}

private extension DefaultSaveFolderSortUseCase {
    func convertToRawString(from option: FolderSortOption) -> String {
        switch option {
        case .title(let dir): return "title|\(convertToRawString(from: dir))"
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
