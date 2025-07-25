@testable import Clipster

final class MockFetchCurrentUserUseCase: FetchCurrentUserUseCase {
    var shouldSucceed = true
    private(set) var didCallExecute = false

    func execute() async -> Result<User, Error> {
        didCallExecute = true
        return shouldSucceed ? .success(MockUser.someUser) : .failure(MockError.fetchFailed)
    }
}
