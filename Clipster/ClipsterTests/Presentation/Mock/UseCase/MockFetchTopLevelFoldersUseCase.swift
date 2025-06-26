@testable import Clipster

final class MockFetchTopLevelFoldersUseCase: FetchTopLevelFoldersUseCase {
    var shouldSucceed = true
    private(set) var didCallExecute = false

    func execute() async -> Result<[Folder], Error> {
        didCallExecute = true
        return shouldSucceed ? .success(MockFolder.rootFolders) : .failure(MockError.deleteFailed)
    }
}
