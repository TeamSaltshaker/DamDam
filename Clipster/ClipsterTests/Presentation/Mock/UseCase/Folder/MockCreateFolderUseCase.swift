@testable import Clipster

final class MockCreateFolderUseCase: CreateFolderUseCase {
    var shouldSucceed = true
    private(set) var didCallExecute = false

    func execute(_ folder: Folder) async -> Result<Void, Error> {
        didCallExecute = true
        return shouldSucceed ? .success(()) : .failure(MockError.createFailed)
    }
}
