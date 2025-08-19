import Foundation

final class DefaultSaveFolderSortOptionUseCase: SaveFolderSortOptionUseCase {
    private let userDefaultsRepository: UserDefaultsRepository

    init(userDefaultsRepository: UserDefaultsRepository) {
        self.userDefaultsRepository = userDefaultsRepository
    }

    func execute(_ option: FolderSortOption) async -> Result<Void, Error> {
        let raw = convertToRawString(from: option)
        userDefaultsRepository.setFolderSortOption(raw)
        return .success(())
    }
}

private extension DefaultSaveFolderSortOptionUseCase {
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
