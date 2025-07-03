@testable import Clipster

final class MockDeleteRecentQueryUseCase: DeleteRecentQueryUseCase {
    private(set) var didCallExecute = false
    private(set) var query: String?

    func execute(_ query: String) {
        didCallExecute = true
        self.query = query
    }
}

