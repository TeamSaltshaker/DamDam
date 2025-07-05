import Foundation
@testable import Clipster

final class MockFetchFolderSortOptionUseCase: FetchFolderSortOptionUseCase {
    var shouldSucceed = true
    private(set) var didCallExecute = false

    func execute() async -> Result<FolderSortOption, Error> {
        didCallExecute = true
        return shouldSucceed ? .success(.title(.ascending)) : .failure(MockError.fetchFailed)
    }
}
