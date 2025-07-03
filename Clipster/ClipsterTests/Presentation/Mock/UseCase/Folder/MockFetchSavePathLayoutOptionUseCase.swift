@testable import Clipster

final class MockFetchSavePathLayoutOptionUseCase: FetchSavePathLayoutOptionUseCase {
    var shouldSucceed = true
    var option: SavePathOption = .expand
    private(set) var didCallExecute = false

    func execute() async -> Result<SavePathOption, Error> {
        didCallExecute = true
        if shouldSucceed {
            return .success(option)
        } else {
            return .failure(MockError.fetchFailed)
        }
    }
}
