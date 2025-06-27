import XCTest
@testable import Clipster

final class FolderReactorTests: XCTestCase {
    private var folder: Folder!
    private var fetchFolderUseCase: FetchFolderUseCase!
    private var deleteFolderUseCase: DeleteFolderUseCase!
    private var visitClipUseCase: VisitClipUseCase!
    private var deleteClipUseCase: DeleteClipUseCase!

    override func setUp() {
        super.setUp()
        folder = MockFolder.someFolder
        fetchFolderUseCase = MockFetchFolderUseCase()
        deleteFolderUseCase = MockDeleteFolderUseCase()
        visitClipUseCase = MockVisitClipUseCase()
        deleteClipUseCase = MockDeleteClipUseCase()
    }

    override func tearDown() {
        deleteClipUseCase = nil
        visitClipUseCase = nil
        deleteFolderUseCase = nil
        fetchFolderUseCase = nil
        folder = nil
        super.tearDown()
    }
}
