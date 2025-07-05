@testable import Clipster

final class MockSearchClipsUseCase: SearchClipsUseCase {
    private(set) var didCallExecute = false
    var clips: [Clip] = []

    func execute(query: String, in clips: [Clip]) -> [Clip] {
        didCallExecute = true
        return clips
    }
}
