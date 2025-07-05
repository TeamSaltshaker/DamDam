@testable import Clipster

final class MockSortFoldersUseCase: SortFoldersUseCase {
    private(set) var didCallExecute = false
    var folders: [Folder]?

    func execute(_ folders: [Folder], by option: FolderSortOption) -> [Folder] {
        didCallExecute = true
        return self.folders ?? folders
    }
}
