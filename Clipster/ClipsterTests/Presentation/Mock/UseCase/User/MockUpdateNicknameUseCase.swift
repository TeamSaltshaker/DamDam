@testable import Clipster

final class MockUpdateNicknameUseCase: UpdateNicknameUseCase {
    var shouldSucceed = true
    private(set) var didCallExecute = false

    func execute(nickname: String) async -> Result<User, Error> {
        didCallExecute = true
        return shouldSucceed ? .success(MockUser.someUser) : .failure(MockError.updateFailed)
    }
}
