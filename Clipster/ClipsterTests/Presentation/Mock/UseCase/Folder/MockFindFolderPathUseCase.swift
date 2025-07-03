@testable import Clipster

final class MockFindFolderPathUseCase: FindFolderPathUseCase {
    var pathToReturn: [Folder]? = nil
    private(set) var didCallExecute = false

    func execute(to folder: Folder, in topLevelFolders: [Folder]) -> [Folder]? {
        didCallExecute = true
        return pathToReturn
    }
}
