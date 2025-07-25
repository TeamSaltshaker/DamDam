@testable import Clipster

final class MockFetchSavePathLayoutOptionUseCase: FetchSavePathLayoutOptionUseCase {
    var shouldSucceed = true
    private(set) var didCallExecute = false
    var option: SavePathOption = .expand

    func execute() async -> Result<SavePathOption, Error> {
        didCallExecute = true
        if shouldSucceed {
            return .success(option)
        } else {
            return .failure(MockError.fetchFailed)
        }
    }
}
