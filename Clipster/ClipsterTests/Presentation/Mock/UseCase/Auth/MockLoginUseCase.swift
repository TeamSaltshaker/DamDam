@testable import Clipster

final class MockLoginUseCase: LoginUseCase {
    var shouldSucceed = true
    private(set) var didCallExecute = false

    func execute(type: LoginType) async -> Result<User, Error> {
        didCallExecute = true
        return shouldSucceed ? .success(MockUser.someUser) : .failure(MockError.loginFailed)
    }
}
