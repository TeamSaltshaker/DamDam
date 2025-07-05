@testable import Clipster

final class MockFilterSubfoldersUseCase: FilterSubfoldersUseCase {
    private(set) var didCallExecute = false

    func execute(_ remove: Folder, from tree: [Folder]) -> [Folder] {
        didCallExecute = true
        return tree.filter { $0.id != remove.id }
    }
}
