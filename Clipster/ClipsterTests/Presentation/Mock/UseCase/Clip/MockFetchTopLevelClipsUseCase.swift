@testable import Clipster

final class MockFetchTopLevelClipsUseCase: FetchTopLevelClipsUseCase {
    var shouldSucceed = true
    private(set) var didCallExecute = false

    func execute() async -> Result<[Clip], Error> {
        didCallExecute = true
        return shouldSucceed ? .success(MockClip.unvisitedClips) : .failure(MockError.deleteFailed)
    }
}
