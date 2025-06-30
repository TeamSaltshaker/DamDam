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

    func test_viewWillAppear_최초진입() {

    }

    func test_viewWillAppear_이후진입() {

    }

    func test_폴더_셀_탭() {

    }

    func test_클립_셀_탭() {

    }

    func test_유효하지_않은_셀_탭() {

    }

    func test_폴더_추가_탭() {

    }

    func test_클립_추가_탭() {

    }

    func test_폴더_상세정보_탭() {
        
    }

    func test_클립_상세정보_탭() {

    }

    func test_유효하지_않은_상세정보_탭() {

    }

    func test_폴더_편집_탭() {

    }

    func test_클립_편집_탭() {

    }

    func test_유효하지_않은_편집_탭() {

    }

    func test_폴더_삭제_탭() {

    }

    func test_클립_삭제_탭() {

    }

    func test_유효하지_않은_삭제_탭() {

    }
}
