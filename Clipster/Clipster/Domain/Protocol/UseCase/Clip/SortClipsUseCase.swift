protocol SortClipsUseCase {
    func execute(_ clips: [Clip], by option: ClipSortOption) -> [Clip]
}
