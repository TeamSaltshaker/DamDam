@testable import Clipster

final class MockSaveClipSortOptionUseCase: SaveClipSortOptionUseCase {
    var shouldSucceed = true
    private(set) var didCallExecute = false

    func execute(_ option: ClipSortOption) async -> Result<Void, Error> {
        didCallExecute = true
        return shouldSucceed ? .success(()) : .failure(MockError.createFailed)
    }
}
