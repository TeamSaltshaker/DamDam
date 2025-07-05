import XCTest
import RxSwift
@testable import Clipster

final class SearchReactorTests: XCTestCase {
    private var fetchAllFoldersUseCase: MockFetchAllFoldersUseCase!
    private var fetchAllClipsUseCase: MockFetchAllClipsUseCase!
    private var fetchRecentQueriesUseCase: MockFetchRecentQueriesUseCase!
    private var fetchRecentVisitedClipsUseCase: MockFetchRecentVisitedClipsUseCase!
    private var saveRecentQueryUseCase: MockSaveRecentQueryUseCase!
    private var deleteRecentQueryUseCase: MockDeleteRecentQueryUseCase!
    private var deleteAllRecentQueriesUseCase: MockDeleteAllRecentQueriesUseCase!
    private var deleteRecentVisitedClipUseCase: MockDeleteRecentVisitedClipUseCase!
    private var deleteAllRecentVisitedClipsUseCase: MockDeleteAllRecentVisitedClipsUseCase!
    private var deleteFolderUseCase: MockDeleteFolderUseCase!
    private var deleteClipUseCase: MockDeleteClipUseCase!
    private var searchFoldersUseCase: MockSearchFoldersUseCase!
    private var searchClipsUseCase: MockSearchClipsUseCase!
    private var visitClipUseCase: MockVisitClipUseCase!
    private var fetchFolderSortOptionUseCase: MockFetchFolderSortOptionUseCase!
    private var fetchClipSortOptionUseCase: MockFetchClipSortOptionUseCase!
    private var sortFoldersUseCase: MockSortFoldersUseCase!
    private var sortClipsUseCase: MockSortClipsUseCase!
    private var reactor: SearchReactor!
    private var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        self.fetchAllFoldersUseCase = MockFetchAllFoldersUseCase()
        self.fetchAllClipsUseCase = MockFetchAllClipsUseCase()
        self.fetchRecentQueriesUseCase = MockFetchRecentQueriesUseCase()
        self.fetchRecentVisitedClipsUseCase = MockFetchRecentVisitedClipsUseCase()
        self.saveRecentQueryUseCase = MockSaveRecentQueryUseCase()
        self.deleteRecentQueryUseCase = MockDeleteRecentQueryUseCase()
        self.deleteAllRecentQueriesUseCase = MockDeleteAllRecentQueriesUseCase()
        self.deleteRecentVisitedClipUseCase = MockDeleteRecentVisitedClipUseCase()
        self.deleteAllRecentVisitedClipsUseCase = MockDeleteAllRecentVisitedClipsUseCase()
        self.deleteFolderUseCase = MockDeleteFolderUseCase()
        self.deleteClipUseCase = MockDeleteClipUseCase()
        self.searchFoldersUseCase = MockSearchFoldersUseCase()
        self.searchClipsUseCase = MockSearchClipsUseCase()
        self.visitClipUseCase = MockVisitClipUseCase()
        self.fetchFolderSortOptionUseCase = MockFetchFolderSortOptionUseCase()
        self.fetchClipSortOptionUseCase = MockFetchClipSortOptionUseCase()
        self.sortFoldersUseCase = MockSortFoldersUseCase()
        self.sortClipsUseCase = MockSortClipsUseCase()
        self.reactor = SearchReactor(
            fetchAllFoldersUseCase: fetchAllFoldersUseCase,
            fetchAllClipsUseCase: fetchAllClipsUseCase,
            fetchRecentQueriesUseCase: fetchRecentQueriesUseCase,
            fetchRecentVisitedClipsUseCase: fetchRecentVisitedClipsUseCase,
            saveRecentQueryUseCase: saveRecentQueryUseCase,
            deleteRecentQueryUseCase: deleteRecentQueryUseCase,
            deleteAllRecentQueriesUseCase: deleteAllRecentQueriesUseCase,
            deleteRecentVisitedClipUseCase: deleteRecentVisitedClipUseCase,
            deleteAllRecentVisitedClipsUseCase: deleteAllRecentVisitedClipsUseCase,
            deleteFolderUseCase: deleteFolderUseCase,
            deleteClipUseCase: deleteClipUseCase,
            searchFoldersUseCase: searchFoldersUseCase,
            searchClipsUseCase: searchClipsUseCase,
            visitClipUseCase: visitClipUseCase,
            fetchFolderSortOptionUseCase: fetchFolderSortOptionUseCase,
            fetchClipSortOptionUseCase: fetchClipSortOptionUseCase,
            sortFoldersUseCase: sortFoldersUseCase,
            sortClipsUseCase: sortClipsUseCase
        )
        self.disposeBag = DisposeBag()
    }

    override func tearDown() {
        super.tearDown()
        fetchAllFoldersUseCase = nil
        fetchAllClipsUseCase = nil
        fetchRecentQueriesUseCase = nil
        fetchRecentVisitedClipsUseCase = nil
        saveRecentQueryUseCase = nil
        deleteRecentQueryUseCase = nil
        deleteAllRecentQueriesUseCase = nil
        deleteRecentVisitedClipUseCase = nil
        deleteAllRecentVisitedClipsUseCase = nil
        deleteFolderUseCase = nil
        deleteClipUseCase = nil
        searchFoldersUseCase = nil
        searchClipsUseCase = nil
        visitClipUseCase = nil
        fetchFolderSortOptionUseCase = nil
        fetchClipSortOptionUseCase = nil
        sortFoldersUseCase = nil
        sortClipsUseCase = nil
        reactor = nil
        disposeBag = nil
    }

    private func waitForViewDidLoad() {
        let expectation = expectation(description: #function)
        reactor.state
            .map(\.phase)
            .filter { $0 == .idle }
            .skip(1)
            .take(1)
            .subscribe(onNext: { _ in expectation.fulfill() })
            .disposed(by: disposeBag)
        reactor.action.onNext(.viewWillAppear)
        wait(for: [expectation], timeout: 1.0)
    }

    func test_뷰_나타났을때_초기_데이터_로드() {
        fetchRecentQueriesUseCase.queries = ["Swift", "ReactorKit"]
        fetchRecentVisitedClipsUseCase.clips = MockClip.unvisitedClips

        let expectation = expectation(description: #function)

        reactor.state
            .map(\.sections)
            .filter { !$0.isEmpty }
            .take(1)
            .subscribe(onNext: { sections in
                XCTAssertEqual(sections.count, 2)
                XCTAssertTrue(self.fetchAllFoldersUseCase.didCallExecute)
                XCTAssertTrue(self.fetchRecentQueriesUseCase.didCallExecute)
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        reactor.action.onNext(.viewWillAppear)

        wait(for: [expectation], timeout: 1.0)
    }

    func test_뷰_나타났을때_초기_데이터_로드_실패() {
        fetchAllFoldersUseCase.shouldSucceed = false
        let expectation = expectation(description: #function)

        reactor.pulse(\.$phase)
            .filter { if case .error = $0 { return true } else { return false } }
            .subscribe(onNext: { _ in
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        reactor.action.onNext(.viewWillAppear)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(matches(reactor.currentState.phase, .error("")))
        XCTAssertTrue(fetchAllFoldersUseCase.didCallExecute)
    }

    func test_쿼리_업데이트시_검색_실행() {
        let query = "T"

        fetchAllFoldersUseCase.folders = [MockFolder.someFolder]
        fetchAllClipsUseCase.clips = [MockClip.someClip]
        searchFoldersUseCase.folders = [MockFolder.someFolder]
        searchClipsUseCase.clips = [MockClip.someClip]

        waitForViewDidLoad()

        let expectation = expectation(description: #function)

        reactor.state
            .map(\.sections)
            .filter { sections in
                guard let firstSection = sections.first else { return false }
                if case .folderResults = firstSection.section { return true }
                return false
            }
            .take(1)
            .subscribe(onNext: { sections in
                XCTAssertEqual(sections.count, 2)
                XCTAssertTrue(self.searchFoldersUseCase.didCallExecute)
                XCTAssertTrue(self.sortFoldersUseCase.didCallExecute)
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        reactor.action.onNext(.updateQuery(query))

        wait(for: [expectation], timeout: 1.0)
    }

    func test_검색_결과가_없을때_처리() {
        let query = "결과 없는 검색어"
        waitForViewDidLoad()

        searchFoldersUseCase.folders = []
        searchClipsUseCase.clips = []

        let expectation = expectation(description: #function)

        reactor.state
            .map(\.sections)
            .filter { $0.isEmpty }
            .take(1)
            .subscribe(onNext: { _ in
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        reactor.action.onNext(.updateQuery(query))

        wait(for: [expectation], timeout: 1.0)

        XCTAssertTrue(reactor.currentState.shouldShowNoResultsView)
    }

    func test_검색어_입력_완료시_최근검색어_저장() {
        let query = "Swift"
        reactor.action.onNext(.updateQuery(query))

        let expectation = expectation(description: #function)

        saveRecentQueryUseCase.onExecute = { expectation.fulfill() }

        reactor.action.onNext(.endEditingQuery)

        wait(for: [expectation], timeout: 1.0)

        XCTAssertTrue(saveRecentQueryUseCase.didCallExecute)
        XCTAssertEqual(saveRecentQueryUseCase.query, query)
    }

    func test_최근_검색어_삭제() {
        let query = "ReactorKit"
        fetchRecentQueriesUseCase.queries = ["Swift", query]
        waitForViewDidLoad()

        XCTAssertEqual(reactor.currentState.sections.first?.items.count, 2)

        let expectation = expectation(description: #function)

        reactor.state
            .map(\.sections)
            .filter { sections in
                let itemCount = sections.first(where: { if case .recentQueries = $0.section { return true } else { return false } })?.items.count
                return itemCount == 1
            }
            .take(1)
            .subscribe(onNext: { _ in
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        reactor.action.onNext(.deleteRecentQueryTapped(query))

        wait(for: [expectation], timeout: 1.0)

        let finalItems = reactor.currentState.sections.first?.items ?? []
        XCTAssertEqual(finalItems.count, 1)
        XCTAssertFalse(finalItems.contains(.recentQuery(query)))
        XCTAssertTrue(deleteRecentQueryUseCase.didCallExecute)
    }

    func test_최근_검색어_전체_삭제() {
        fetchRecentQueriesUseCase.queries = ["Swift", "ReactorKit"]
        waitForViewDidLoad()

        let expectation = expectation(description: #function)

        reactor.state.map(\.sections)
            .filter { sections in
                !sections.contains { if case .recentQueries = $0.section { return true } else { return false } }
            }
            .take(1)
            .subscribe(onNext: { _ in
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        reactor.action.onNext(.deleteAllRecentQueriesTapped)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertFalse(reactor.currentState.sections.contains { if case .recentQueries = $0.section { return true } else { return false } })
        XCTAssertTrue(deleteAllRecentQueriesUseCase.didCallExecute)
    }

    func test_검색결과_폴더_삭제() {
        let query = "iOS"
        let folder = MockFolder.someFolder

        fetchAllFoldersUseCase.folders = [folder]
        searchFoldersUseCase.folders = [folder]
        deleteFolderUseCase.shouldSucceed = true

        waitForViewDidLoad()

        let searchExpectation = expectation(description: #function)
        reactor.state
            .map(\.sections)
            .filter { !$0.isEmpty && $0.first?.section.title == "폴더" }
            .take(1)
            .subscribe(onNext: { _ in searchExpectation.fulfill() })
            .disposed(by: disposeBag)

        reactor.action.onNext(.updateQuery(query))
        wait(for: [searchExpectation], timeout: 1.0)

        let deletionExpectation = expectation(description: #function)

        reactor.state
            .map(\.sections)
            .filter { $0.isEmpty }
            .take(1)
            .subscribe(onNext: { _ in
                deletionExpectation.fulfill()
            })
            .disposed(by: disposeBag)

        let item = SearchReactor.SearchItem.folder(folder: FolderDisplayMapper.map(folder), query: query)
        reactor.action.onNext(.deleteTapped(item))

        wait(for: [deletionExpectation], timeout: 1.0)
        XCTAssertTrue(reactor.currentState.sections.isEmpty)
        XCTAssertTrue(deleteFolderUseCase.didCallExecute)
    }

    func test_클립_아이템_탭시_웹뷰() {
        let clip = MockClip.someClip
        fetchAllClipsUseCase.clips = [clip]
        waitForViewDidLoad()

        let item = SearchReactor.SearchItem.recentVisitedClip(ClipDisplayMapper.map(clip))
        let expectation = expectation(description: #function)

        reactor.pulse(\.$route).compactMap { $0 }.subscribe(onNext: { route in
            if case .showWebView(let url) = route {
                XCTAssertEqual(url, clip.url)
                expectation.fulfill()
            }
        }).disposed(by: disposeBag)

        reactor.action.onNext(.itemTapped(item))

        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(visitClipUseCase.didCallExecute)
    }

    func test_검색결과_클립_삭제() {
        let query = "Example"
        let clip = MockClip.someClip

        fetchAllClipsUseCase.clips = [clip]
        searchClipsUseCase.clips = [clip]
        deleteClipUseCase.shouldSucceed = true

        waitForViewDidLoad()

        let searchExpectation = expectation(description: #function)
        reactor.state
            .map(\.sections)
            .filter { !$0.isEmpty && $0.first?.section.title == "클립" }
            .take(1)
            .subscribe(onNext: { _ in searchExpectation.fulfill() })
            .disposed(by: disposeBag)

        reactor.action.onNext(.updateQuery(query))
        wait(for: [searchExpectation], timeout: 1.0)

        let deletionExpectation = expectation(description: #function)

        reactor.state
            .map(\.sections)
            .filter { $0.isEmpty }
            .take(1)
            .subscribe(onNext: { _ in
                deletionExpectation.fulfill()
            })
            .disposed(by: disposeBag)

        let item = SearchReactor.SearchItem.clip(clip: ClipDisplayMapper.map(clip), query: query)
        reactor.action.onNext(.deleteTapped(item))

        wait(for: [deletionExpectation], timeout: 1.0)
        XCTAssertTrue(reactor.currentState.sections.isEmpty)
        XCTAssertTrue(deleteClipUseCase.didCallExecute)
    }
}

extension SearchReactor.State.Phase: @retroactive Equatable {
    public static func == (lhs: SearchReactor.State.Phase, rhs: SearchReactor.State.Phase) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle),
             (.loading, .loading),
             (.success, .success):
            return true
        case (.error(let a), .error(let b)):
            return a == b
        default:
            return false
        }
    }
}

extension SearchReactor.State.Route: @retroactive Equatable {
    public static func == (lhs: SearchReactor.State.Route, rhs: SearchReactor.State.Route) -> Bool {
        switch (lhs, rhs) {
        case (.showWebView(let a), .showWebView(let b)):
            return a == b
        case (.showFolderView(let a), .showFolderView(let b)):
            return a.id == b.id
        case (.showEditFolder(let aParent, let aFolder), .showEditFolder(let bParent, let bFolder)):
            return aParent?.id == bParent?.id && aFolder.id == bFolder.id
        case (.showEditClip(let a), .showEditClip(let b)):
            return a.id == b.id
        case (.showDetailClip(let a), .showDetailClip(let b)):
            return a.id == b.id
        default:
            return false
        }
    }
}

private func matches(_ phase: SearchReactor.State.Phase?, _ expected: SearchReactor.State.Phase) -> Bool {
    guard let phase = phase else { return false }
    switch (phase, expected) {
    case (.idle, .idle), (.loading, .loading), (.success, .success):
        return true
    case (.error, .error):
        return true
    default:
        return false
    }
}
