import Foundation
@testable import Clipster

final class MockFetchFolderUseCase: FetchFolderUseCase {
    var shouldSucceed = true
    private(set) var didCallExecute = false

    func execute(id: UUID) async -> Result<Clipster.Folder, Error> {
        didCallExecute = true
        return shouldSucceed ? .success(MockFolder.someFolder) : .failure(MockError.fetchFailed)
    }
}
