import XCTest
import RxSwift
@testable import Clipster

final class FolderReactorTests: XCTestCase {
    private var folder: Folder!
    private var fetchFolderUseCase: MockFetchFolderUseCase!
    private var fetchFolderSortOptionUseCase: MockFetchFolderSortOptionUseCase!
    private var fetchClipSortOptionUseCase: MockFetchClipSortOptionUseCase!
    private var sortFoldersUseCase: MockSortFoldersUseCase!
    private var sortClipsUseCase: MockSortClipsUseCase!
    private var deleteFolderUseCase: MockDeleteFolderUseCase!
    private var visitClipUseCase: MockVisitClipUseCase!
    private var deleteClipUseCase: MockDeleteClipUseCase!
    private var reactor: FolderReactor!
    private var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        folder = MockFolder.someFolder
        fetchFolderUseCase = MockFetchFolderUseCase()
        fetchFolderSortOptionUseCase = MockFetchFolderSortOptionUseCase()
        fetchClipSortOptionUseCase = MockFetchClipSortOptionUseCase()
        sortFoldersUseCase = MockSortFoldersUseCase()
        sortClipsUseCase = MockSortClipsUseCase()
        deleteFolderUseCase = MockDeleteFolderUseCase()
        visitClipUseCase = MockVisitClipUseCase()
        deleteClipUseCase = MockDeleteClipUseCase()
        reactor = FolderReactor(
            folder: folder,
            fetchFolderUseCase: fetchFolderUseCase,
            fetchFolderSortOptionUseCase: fetchFolderSortOptionUseCase,
            fetchClipSortOptionUseCase: fetchClipSortOptionUseCase,
            sortFoldersUseCase: sortFoldersUseCase,
            sortClipsUseCase: sortClipsUseCase,
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
        sortClipsUseCase = nil
        sortFoldersUseCase = nil
        fetchClipSortOptionUseCase = nil
        fetchFolderSortOptionUseCase = nil
        fetchFolderUseCase = nil
        folder = nil
        super.tearDown()
    }

    func test_viewWillAppear() {
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

        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(phaseResults, [.loading, .success])
        XCTAssertTrue(fetchFolderUseCase.didCallExecute)
        XCTAssertTrue(fetchFolderSortOptionUseCase.didCallExecute)
        XCTAssertTrue(fetchClipSortOptionUseCase.didCallExecute)
        XCTAssertTrue(sortFoldersUseCase.didCallExecute)
        XCTAssertTrue(sortClipsUseCase.didCallExecute)
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
        XCTAssertEqual(routeResult, .folderView(folder.folders[0]))
    }

    func test_클립_셀_탭() {
        let phaseExpectation = expectation(description: #function + " - phase")
        var phaseResults = [FolderReactor.Phase]()
        let routeExpectation = expectation(description: #function + " - route")
        var routeResult: FolderReactor.Route?

        reactor.pulse(\.$phase)
            .compactMap { $0 }
            .skip(1)
            .subscribe { phase in
                phaseResults.append(phase)
                if phaseResults.count == 2 {
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
        XCTAssertEqual(phaseResults, [.loading, .success])
        XCTAssertTrue(visitClipUseCase.didCallExecute)
        XCTAssertEqual(routeResult, .webView(folder.clips[0].url))
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
        XCTAssertFalse(visitClipUseCase.didCallExecute)
    }

    func test_폴더_추가_탭() {
        let expectation = expectation(description: #function)
        var routeResult: FolderReactor.Route?

        reactor.pulse(\.$route)
            .compactMap { $0 }
            .subscribe { route in
                routeResult = route
                expectation.fulfill()
            }
            .disposed(by: disposeBag)

        reactor.action.onNext(.didTapAddFolderButton)

        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(routeResult, .editFolderView(folder, nil))
    }

    func test_클립_추가_탭() {
        let expectation = expectation(description: #function)
        var routeResult: FolderReactor.Route?

        reactor.pulse(\.$route)
            .compactMap { $0 }
            .subscribe { route in
                routeResult = route
                expectation.fulfill()
            }
            .disposed(by: disposeBag)

        reactor.action.onNext(.didTapAddClipButton)

        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(routeResult, .editClipViewForAdd(folder))
    }

    func test_폴더_상세정보_탭() {
        let indexPath = IndexPath(item: 0, section: 0)
        reactor.action.onNext(.didTapDetailButton(indexPath))
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 1.0))

        XCTAssertEqual(reactor.currentState.phase, .idle)
        XCTAssertNil(reactor.currentState.route)
    }

    func test_클립_상세정보_탭() {
        let expectation = expectation(description: #function)
        var routeResult: FolderReactor.Route?

        reactor.pulse(\.$route)
            .compactMap { $0 }
            .subscribe { route in
                routeResult = route
                expectation.fulfill()
            }
            .disposed(by: disposeBag)

        let indexPath = IndexPath(item: 0, section: 1)
        reactor.action.onNext(.didTapDetailButton(indexPath))

        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(routeResult, .clipDetailView(folder.clips[0]))
    }

    func test_유효하지_않은_상세정보_탭() {
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
        reactor.action.onNext(.didTapDetailButton(invalidIndexPath))

        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(phaseResult, .error("Invalid section"))
    }

    func test_폴더_편집_탭() {
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
        reactor.action.onNext(.didTapEditButton(indexPath))

        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(routeResult, .editFolderView(folder, folder.folders[0]))
    }

    func test_클립_편집_탭() {
        let expectation = expectation(description: #function)
        var routeResult: FolderReactor.Route?

        reactor.pulse(\.$route)
            .compactMap { $0 }
            .subscribe { route in
                routeResult = route
                expectation.fulfill()
            }
            .disposed(by: disposeBag)

        let indexPath = IndexPath(item: 0, section: 1)
        reactor.action.onNext(.didTapEditButton(indexPath))

        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(routeResult, .editClipViewForEdit(folder.clips[0]))
    }

    func test_유효하지_않은_편집_탭() {
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
        reactor.action.onNext(.didTapEditButton(invalidIndexPath))

        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(phaseResult, .error("Invalid section"))
    }

    func test_폴더_삭제_탭() {
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

        let indexPath = IndexPath(item: 0, section: 0)
        reactor.action.onNext(.didTapDeleteButton(indexPath))

        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(phaseResults, [.loading, .success])
        XCTAssertTrue(deleteFolderUseCase.didCallExecute)
        XCTAssertTrue(fetchFolderUseCase.didCallExecute)
        XCTAssertTrue(fetchFolderSortOptionUseCase.didCallExecute)
        XCTAssertTrue(fetchClipSortOptionUseCase.didCallExecute)
        XCTAssertTrue(sortFoldersUseCase.didCallExecute)
        XCTAssertTrue(sortClipsUseCase.didCallExecute)
    }

    func test_클립_삭제_탭() {
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

        let indexPath = IndexPath(item: 0, section: 1)
        reactor.action.onNext(.didTapDeleteButton(indexPath))

        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(phaseResults, [.loading, .success])
        XCTAssertTrue(deleteClipUseCase.didCallExecute)
        XCTAssertTrue(fetchFolderUseCase.didCallExecute)
        XCTAssertTrue(fetchFolderSortOptionUseCase.didCallExecute)
        XCTAssertTrue(fetchClipSortOptionUseCase.didCallExecute)
        XCTAssertTrue(sortFoldersUseCase.didCallExecute)
        XCTAssertTrue(sortClipsUseCase.didCallExecute)
    }

    func test_유효하지_않은_삭제_탭() {
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
        reactor.action.onNext(.didTapDeleteButton(invalidIndexPath))

        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(phaseResult, .error("Invalid section"))
        XCTAssertFalse(deleteFolderUseCase.didCallExecute)
        XCTAssertFalse(deleteClipUseCase.didCallExecute)
        XCTAssertFalse(fetchFolderUseCase.didCallExecute)
        XCTAssertFalse(fetchFolderSortOptionUseCase.didCallExecute)
        XCTAssertFalse(fetchClipSortOptionUseCase.didCallExecute)
        XCTAssertFalse(sortFoldersUseCase.didCallExecute)
        XCTAssertFalse(sortClipsUseCase.didCallExecute)
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

extension FolderReactor.Route: @retroactive Equatable {
    public static func == (lhs: FolderReactor.Route, rhs: FolderReactor.Route) -> Bool {
        switch (lhs, rhs) {
        case (.editClipViewForAdd(let a), .editClipViewForAdd(let b)):
            return a.id == b.id
        case (.editClipViewForEdit(let a), .editClipViewForEdit(let b)):
            return a.id == b.id
        case (.editFolderView(let a, let b), .editFolderView(let c, let d)):
            return a.id == c.id && b?.id == d?.id
        case (.folderView(let a), .folderView(let b)):
            return a.id == b.id
        case (.clipDetailView(let a), .clipDetailView(let b)):
            return a.id == b.id
        case (.webView(let a), .webView(let b)):
            return a.absoluteString == b.absoluteString
        default:
            return false
        }
    }
}
