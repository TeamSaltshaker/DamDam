@testable import Clipster

final class MockSearchFoldersUseCase: SearchFoldersUseCase {
    private(set) var didCallExecute = false
    var folders: [Folder] = []

    func execute(query: String, in folders: [Folder]) -> [Folder] {
        didCallExecute = true
        return folders
    }
}
