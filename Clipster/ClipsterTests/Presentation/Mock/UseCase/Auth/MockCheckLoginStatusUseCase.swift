@testable import Clipster

final class MockCheckLoginStatusUseCase: CheckLoginStatusUseCase {
    var shouldSucceed = true
    private(set) var didCallExecute = false

    func execute() async -> Bool {
        didCallExecute = true
        return shouldSucceed
    }
}
