@testable import Clipster

final class MockDeleteAllRecentQueriesUseCase: DeleteAllRecentQueriesUseCase {
    private(set) var didCallExecute = false

    func execute() {
        didCallExecute = true
    }
}
