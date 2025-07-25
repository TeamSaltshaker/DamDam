@testable import Clipster

final class MockSaveSavePathLayoutOptionUseCase: SaveSavePathLayoutOptionUseCase {
    var shouldSucceed = true
    private(set) var didCallExecute = false

    func execute(_ option: SavePathOption) async -> Result<Void, Error> {
        didCallExecute = true
        return shouldSucceed ? .success(()) : .failure(MockError.createFailed)
    }
}
