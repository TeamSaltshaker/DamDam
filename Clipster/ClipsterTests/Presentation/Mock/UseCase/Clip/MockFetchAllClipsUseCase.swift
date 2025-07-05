@testable import Clipster

final class MockFetchAllClipsUseCase: FetchAllClipsUseCase {
    var shouldSucceed = true
    private(set) var didCallExecute = false
    var clips: [Clip] = []

    func execute() async -> Result<[Clip], Error> {
        didCallExecute = true
        if shouldSucceed {
            return .success(clips)
        } else {
            return .failure(MockError.fetchFailed)
        }
    }
}
