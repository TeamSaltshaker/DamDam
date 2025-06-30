import XCTest
import RxSwift
@testable import Clipster

final class FolderReactorTests: XCTestCase {
    private var folder: Folder!
    private var fetchFolderUseCase: FetchFolderUseCase!
    private var deleteFolderUseCase: DeleteFolderUseCase!
    private var visitClipUseCase: VisitClipUseCase!
    private var deleteClipUseCase: DeleteClipUseCase!
    private var reactor: FolderReactor!
    private var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        folder = MockFolder.someFolder
        fetchFolderUseCase = MockFetchFolderUseCase()
        deleteFolderUseCase = MockDeleteFolderUseCase()
        visitClipUseCase = MockVisitClipUseCase()
        deleteClipUseCase = MockDeleteClipUseCase()
        reactor = FolderReactor(
            folder: folder,
            fetchFolderUseCase: fetchFolderUseCase,
            deleteFolderUseCase: deleteFolderUseCase,
            visitClipUseCase: visitClipUseCase,
            deleteClipUseCase: deleteClipUseCase,
        )
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        disposeBag = nil
        reactor = nil
        deleteClipUseCase = nil
        visitClipUseCase = nil
        deleteFolderUseCase = nil
        fetchFolderUseCase = nil
        folder = nil
        super.tearDown()
    }

    func test_viewWillAppear_최초진입() {
        reactor.action.onNext(.viewWillAppear)

        XCTAssertEqual(reactor.currentState.phase, .idle)
        XCTAssertNil(reactor.currentState.route)
        XCTAssertFalse((fetchFolderUseCase as! MockFetchFolderUseCase).didCallExecute)
    }

    func test_viewWillAppear_이후진입() {
        let expectation = expectation(description: #function)
        var phaseResults = [FolderReactor.Phase]()

        reactor.pulse(\.$phase)
            .compactMap { $0 }
            .skip(1)
            .subscribe { phase in
                phaseResults.append(phase)
                if phaseResults.count == 2 {
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        reactor.action.onNext(.viewWillAppear)
        reactor.action.onNext(.viewWillAppear)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(phaseResults, [.loading, .success])
        XCTAssertTrue((fetchFolderUseCase as! MockFetchFolderUseCase).didCallExecute)
    }

    func test_폴더_셀_탭() {
        let expectation = expectation(description: #function)
        var routeResult: FolderReactor.Route?

        reactor.pulse(\.$route)
            .compactMap { $0 }
            .subscribe { route in
                routeResult = route
                expectation.fulfill()
            }
            .disposed(by: disposeBag)

        let indexPath = IndexPath(item: 0, section: 0)
        reactor.action.onNext(.didTapCell(indexPath))

        waitForExpectations(timeout: 1.0)
        XCTAssertTrue({
            if case .folderView = routeResult { return true }
            else { return false }
        }())
    }

    func test_클립_셀_탭() {
        let phaseExpectation = expectation(description: #function + " - phase")
        var phaseResults = [FolderReactor.Phase]()
        let routeExpectation = expectation(description: #function + " - route")
        var routeResult: FolderReactor.Route?

        reactor.pulse(\.$phase)
            .compactMap { $0 }
            .subscribe { phase in
                phaseResults.append(phase)
                if phaseResults.count == 3 {
                    phaseExpectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        reactor.pulse(\.$route)
            .compactMap { $0 }
            .subscribe { route in
                routeResult = route
                routeExpectation.fulfill()
            }
            .disposed(by: disposeBag)

        let indexPath = IndexPath(item: 0, section: 1)
        reactor.action.onNext(.didTapCell(indexPath))

        wait(for: [phaseExpectation, routeExpectation], timeout: 1.0)
        XCTAssertEqual(phaseResults, [.idle, .loading, .success])
        XCTAssertTrue((visitClipUseCase as! MockVisitClipUseCase).didCallExecute)
        XCTAssertTrue({
            if case .webView = routeResult { return true }
            else { return false }
        }())
    }

    func test_유효하지_않은_셀_탭() {
        let expectation = expectation(description: #function)
        var phaseResult: FolderReactor.Phase?

        reactor.pulse(\.$phase)
            .compactMap { $0 }
            .skip(1)
            .subscribe { phase in
                phaseResult = phase
                expectation.fulfill()
            }
            .disposed(by: disposeBag)

        let invalidIndexPath = IndexPath(item: 99, section: 99)
        reactor.action.onNext(.didTapCell(invalidIndexPath))

        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(phaseResult, .error("Invalid section"))
        XCTAssertFalse((visitClipUseCase as! MockVisitClipUseCase).didCallExecute)
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

extension FolderReactor.Phase: @retroactive Equatable {
    public static func == (lhs: FolderReactor.Phase, rhs: FolderReactor.Phase) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.success, .success):
            return true
        case (.error(let a), .error(let b)):
            return a == b
        default:
            return false
        }
    }
}
