@testable import Clipster

final class MockVisitClipUseCase: VisitClipUseCase {
    var shouldSucceed = true
    private(set) var didCallExecute = false

    func execute(clip: Clip) async -> Result<Void, Error> {
        didCallExecute = true
        return shouldSucceed ? .success(()) : .failure(MockError.markVisitClipFailed)
    }
}
