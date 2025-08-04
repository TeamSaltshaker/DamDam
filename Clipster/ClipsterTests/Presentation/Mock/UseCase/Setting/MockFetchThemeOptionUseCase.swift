@testable import Clipster

final class MockFetchThemeOptionUseCase: FetchThemeOptionUseCase {
    var shouldSucceed = true
    private(set) var didCallExecute = false
    var option: ThemeOption = .light

    func execute() async -> Result<ThemeOption, Error> {
        didCallExecute = true
        return shouldSucceed ? .success(option) : .failure(MockError.fetchFailed)
    }
}
