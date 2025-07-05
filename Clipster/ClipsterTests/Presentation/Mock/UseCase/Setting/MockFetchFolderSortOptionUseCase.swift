@testable import Clipster

final class MockFetchFolderSortOptionUseCase: FetchFolderSortOptionUseCase {
    var shouldSucceed = true
    private(set) var didCallExecute = false
    var option: FolderSortOption = .createdAt(.descending)

    func execute() async -> Result<FolderSortOption, Error> {
        didCallExecute = true
        if shouldSucceed {
            return .success(option)
        } else {
            return .failure(MockError.fetchFailed)
        }
    }
}
