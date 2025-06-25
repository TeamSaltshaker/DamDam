final class DefaultSortClipsUseCase: SortClipsUseCase {
    func execute(_ clips: [Clip], by option: ClipSortOption) -> [Clip] {
        clips.sorted {
            switch option {
            case .title(let direction):
                return SortHelper.compare($0.title, $1.title, direction)
            case .lastVisitedAt(let direction):
                return SortHelper.compare($0.lastVisitedAt ?? .distantPast, $1.lastVisitedAt ?? .distantPast, direction)
            case .createdAt(let direction):
                return SortHelper.compare($0.createdAt, $1.createdAt, direction)
            case .updatedAt(let direction):
                return SortHelper.compare($0.updatedAt, $1.updatedAt, direction)
            }
        }
    }
}
