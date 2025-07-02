@testable import Clipster

final class MockCanSaveFolderUseCase: CanSaveFolderUseCase {
    var shouldSucceed = true
    private(set) var didCallExecute = false

    func execute(title: String) -> Bool {
        didCallExecute = true
        guard shouldSucceed else {
            return false
        }
        return !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
