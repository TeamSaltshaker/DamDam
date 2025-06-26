@testable import Clipster

final class MockDeleteClipUseCase: DeleteClipUseCase {
    var shouldSucceed = true
    private(set) var didCallExecute = false

    func execute(_ clip: Clip) async -> Result<Void, Error> {
        didCallExecute = true
        return shouldSucceed ? .success(()) : .failure(MockError.deleteFailed)
    }
}
