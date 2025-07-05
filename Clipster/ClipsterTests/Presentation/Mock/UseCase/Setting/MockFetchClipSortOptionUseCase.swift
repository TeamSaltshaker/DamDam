@testable import Clipster

final class MockFetchClipSortOptionUseCase: FetchClipSortOptionUseCase {
    var shouldSucceed = true
    private(set) var didCallExecute = false
    var option: ClipSortOption = .createdAt(.descending)

    func execute() async -> Result<ClipSortOption, Error> {
        didCallExecute = true
        if shouldSucceed {
            return .success(option)
        } else {
            return .failure(MockError.fetchFailed)
        }
    }
}
