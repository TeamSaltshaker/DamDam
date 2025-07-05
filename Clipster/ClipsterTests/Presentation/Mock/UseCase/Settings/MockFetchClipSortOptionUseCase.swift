import Foundation
@testable import Clipster

final class MockFetchClipSortOptionUseCase: FetchClipSortOptionUseCase {
    var shouldSucceed = true
    private(set) var didCallExecute = false

    func execute() async -> Result<ClipSortOption, Error> {
        didCallExecute = true
        return shouldSucceed ? .success(.title(.ascending)) : .failure(MockError.fetchFailed)
    }
}
