@testable import Clipster

final class MockFetchAllFoldersUseCase: FetchAllFoldersUseCase {
    var shouldSucceed = true
    private(set) var didCallExecute = false
    var folders: [Folder] = []

    func execute() async -> Result<[Folder], Error> {
        didCallExecute = true
        if shouldSucceed {
            return .success(folders)
        } else {
            return .failure(MockError.fetchFailed)
        }
    }
}
