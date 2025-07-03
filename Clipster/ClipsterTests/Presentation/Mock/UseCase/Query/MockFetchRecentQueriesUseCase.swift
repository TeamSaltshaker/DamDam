@testable import Clipster

final class MockFetchRecentQueriesUseCase: FetchRecentQueriesUseCase {
    private(set) var didCallExecute = false
    var queries: [String] = []

    func execute() -> [String] {
        didCallExecute = true
        return queries
    }
}
