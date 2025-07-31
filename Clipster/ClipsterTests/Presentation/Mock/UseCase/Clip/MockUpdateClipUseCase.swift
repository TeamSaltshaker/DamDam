@testable import Clipster

final class MockUpdateClipUseCase: UpdateClipUseCase {
    private(set) var didCallExecute: Bool = false
    var shouldSucceed: Bool = true
    private(set) var receivedClip: Clip?

    func execute(clip: Clip) async -> Result<Void, Error> {
        didCallExecute = true
        receivedClip = clip
        return shouldSucceed ? .success(()) : .failure(MockError.updateFailed)
    }
}
