@testable import Clipster

final class MockSanitizeFolderTitleUseCase: SanitizeFolderTitleUseCase {
    private(set) var didCallExecute = false

    func execute(title: String) -> String {
        didCallExecute = true
        return String(title.prefix(100))
    }
}
