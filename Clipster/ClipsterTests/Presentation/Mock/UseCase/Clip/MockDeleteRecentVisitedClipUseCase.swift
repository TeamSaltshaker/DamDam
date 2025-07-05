@testable import Clipster

final class MockDeleteRecentVisitedClipUseCase: DeleteRecentVisitedClipUseCase {
    private(set) var didCallExecute = false
    private(set) var id: String?

    func execute(_ id: String) {
        didCallExecute = true
        self.id = id
    }
}
