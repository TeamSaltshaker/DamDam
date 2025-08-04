@testable import Clipster

final class MockSaveThemeOptionUseCase: SaveThemeOptionUseCase {
    var shouldSucceed = true
    private(set) var didCallExecute = false

    func execute(_ theme: ThemeOption) async -> Result<Void, Error> {
        didCallExecute = true
        return shouldSucceed ? .success(()) : .failure(MockError.createFailed)
    }
}
