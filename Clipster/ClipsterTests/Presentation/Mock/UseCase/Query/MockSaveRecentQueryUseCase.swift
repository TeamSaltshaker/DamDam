@testable import Clipster

final class MockSaveRecentQueryUseCase: SaveRecentQueryUseCase {
    private(set) var didCallExecute = false
    private(set) var query: String?

    var onExecute: (() -> Void)?

    func execute(_ query: String) {
        didCallExecute = true
        self.query = query
        onExecute?()
    }
}
