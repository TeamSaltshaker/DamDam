@testable import Clipster

final class MockLogoutUseCase: LogoutUseCase {
    var shouldSucceed = true
    private(set) var didCallExecute = false

    func execute() async -> Result<Void, Error> {
        didCallExecute = true
        return shouldSucceed ? .success(()) : .failure(MockError.logoutFailed)
    }
}
