@testable import Clipster

final class MockDeleteAllRecentVisitedClipsUseCase: DeleteAllRecentVisitedClipsUseCase {
    private(set) var didCallExecute = false

    func execute() {
        didCallExecute = true
    }
}
