import Foundation
@testable import Clipster

final class MockFetchClipUseCase: FetchClipUseCase {
    var shouldSucceed = true
    private(set) var didCallExecute = false

    func execute(id: UUID) async -> Result<Clip, Error> {
        didCallExecute = true
        return shouldSucceed ? .success(MockClip.someClip) : .failure(MockError.fetchFailed)
    }
}
