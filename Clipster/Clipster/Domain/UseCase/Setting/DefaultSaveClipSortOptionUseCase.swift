import Foundation

final class DefaultSaveClipSortOptionUseCase: SaveClipSortOptionUseCase {
    private let userDefaultsRepository: UserDefaultsRepository

    init(userDefaultsRepository: UserDefaultsRepository) {
        self.userDefaultsRepository = userDefaultsRepository
    }

    func execute(_ option: ClipSortOption) async -> Result<Void, Error> {
        let raw = convertToRawString(from: option)
        userDefaultsRepository.setClipSortOption(raw)
        return .success(())
    }
}

private extension DefaultSaveClipSortOptionUseCase {
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
