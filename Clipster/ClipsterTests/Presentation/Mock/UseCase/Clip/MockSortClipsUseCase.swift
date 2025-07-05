@testable import Clipster

final class MockSortClipsUseCase: SortClipsUseCase {
    private(set) var didCallExecute = false
    var clips: [Clip]?

    func execute(_ clips: [Clip], by option: ClipSortOption) -> [Clip] {
        didCallExecute = true
        return self.clips ?? clips
    }
}
