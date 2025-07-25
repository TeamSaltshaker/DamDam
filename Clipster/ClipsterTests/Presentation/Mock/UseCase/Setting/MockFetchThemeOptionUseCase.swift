@testable import Clipster

final class MockFetchThemeOptionUseCase: FetchThemeOptionUseCase {
    var shouldSucceed = true
    private(set) var didCallExecute = false

    func execute() async -> Result<ThemeOption, Error> {
        didCallExecute = true
        return shouldSucceed ? .success(.light) : .failure(MockError.fetchFailed)
    }
}
