import XCTest
import RxSwift
@testable import Clipster

final class FolderSelectorReactorTests: XCTestCase {
    private var reactor: FolderSelectorReactor!
    private var fetchTopLevelFoldersUseCase: MockFetchTopLevelFoldersUseCase!
    private var findFolderPathUseCase: MockFindFolderPathUseCase!
    private var filterSubfoldersUseCase: MockFilterSubfoldersUseCase!
    private var fetchLayoutOptionUseCase: MockFetchSavePathLayoutOptionUseCase!
    private var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        self.fetchTopLevelFoldersUseCase = MockFetchTopLevelFoldersUseCase()
        self.findFolderPathUseCase = MockFindFolderPathUseCase()
        self.filterSubfoldersUseCase = MockFilterSubfoldersUseCase()
        self.fetchLayoutOptionUseCase = MockFetchSavePathLayoutOptionUseCase()
        self.disposeBag = DisposeBag()
    }

    override func tearDown() {
        self.reactor = nil
        self.fetchTopLevelFoldersUseCase = nil
        self.findFolderPathUseCase = nil
        self.filterSubfoldersUseCase = nil
        self.fetchLayoutOptionUseCase = nil
        self.disposeBag = nil
        super.tearDown()
    }

    private func createReactor(parentFolder: Folder? = nil, folder: Folder? = nil) {
        self.reactor = FolderSelectorReactor(
            fetchTopLevelFoldersUseCase: fetchTopLevelFoldersUseCase,
            findFolderPathUseCase: findFolderPathUseCase,
            filterSubfoldersUseCase: filterSubfoldersUseCase,
            fetchSavePathLayoutOptionUseCase: fetchLayoutOptionUseCase,
            parentFolder: parentFolder,
            folder: folder
        )
    }

    func test_뷰_로드_실패() {
        createReactor()
        fetchTopLevelFoldersUseCase.shouldSucceed = false
        let expectation = expectation(description: #function)
        var phaseResults: [FolderSelectorReactor.State.Phase] = []

        reactor.pulse(\.$phase)
            .skip(1)
            .subscribe(onNext: { phase in
                phaseResults.append(phase)
                if matches(phase, .error("")) {
                    expectation.fulfill()
                }
            })
            .disposed(by: disposeBag)

        reactor.action.onNext(.viewDidLoad)

        wait(for: [expectation], timeout: 1.0)

        XCTAssertTrue(phaseResults.contains(where: { matches($0, .error("")) }))
    }

    func test_아코디언_모드_초기화() {
        let folder = MockFolder.someFolder.folders.first!
        createReactor(parentFolder: folder)
        fetchLayoutOptionUseCase.option = .expand
        findFolderPathUseCase.pathToReturn = [MockFolder.someFolder, folder]

        waitForViewDidLoad()

        XCTAssertTrue(reactor.currentState.isAccordion)
        XCTAssertEqual(reactor.currentState.highlightedFolderID, folder.id)
        XCTAssertTrue(reactor.currentState.expandedFolderIDs.contains(MockFolder.someFolder.id))
    }

    func test_아코디언_모드_폴더_선택시_하이라이트_변경() {
        createReactor()
        fetchLayoutOptionUseCase.option = .expand
        waitForViewDidLoad()

        let folder = MockFolder.someFolder.folders.first!
        reactor.action.onNext(.selectedFolder(id: folder.id))

        XCTAssertEqual(reactor.currentState.highlightedFolderID, folder.id)
    }

    func test_아코디언_모드_폴더_펼치기_토글() {
        createReactor()
        fetchLayoutOptionUseCase.option = .expand
        waitForViewDidLoad()

        reactor.action.onNext(.toggleExpansion(id: MockFolder.someFolder.id))
        XCTAssertTrue(reactor.currentState.expandedFolderIDs.contains(MockFolder.someFolder.id))

        reactor.action.onNext(.toggleExpansion(id: MockFolder.someFolder.id))
        XCTAssertFalse(reactor.currentState.expandedFolderIDs.contains(MockFolder.someFolder.id))
    }

    func test_아코디언_모드_확인_버튼_탭() {
        createReactor()
        fetchLayoutOptionUseCase.option = .expand
        waitForViewDidLoad()

        let targetFolder = MockFolder.rootFolders.first!
        let accordionExpectation = expectation(description: #function)

        reactor.state
            .map(\.highlightedFolderID)
            .filter { $0 == targetFolder.id }
            .take(1)
            .subscribe(onNext: { _ in
                accordionExpectation.fulfill()
            })
            .disposed(by: disposeBag)

        reactor.action.onNext(.selectedFolder(id: targetFolder.id))

        wait(for: [accordionExpectation], timeout: 1.0)

        let selectionExpectation = expectation(description: #function)
        var finalPhase: FolderSelectorReactor.State.Phase?

        reactor.pulse(\.$phase)
            .filter { if case .success = $0 { return true } else { return false } }
            .subscribe(onNext: { phase in
                finalPhase = phase
                selectionExpectation.fulfill()
            })
            .disposed(by: disposeBag)

        reactor.action.onNext(.selectButtonTapped)

        wait(for: [selectionExpectation], timeout: 1.0)
        if case .success(let selectedFolder) = finalPhase {
            XCTAssertEqual(selectedFolder?.id, targetFolder.id)
        } else {
            XCTFail()
        }
    }

    func test_리스트_모드_초기화() {
        let uikitFolder = MockFolder.someFolder.folders.first!
        createReactor(parentFolder: uikitFolder)
        fetchLayoutOptionUseCase.option = .skip
        findFolderPathUseCase.pathToReturn = [MockFolder.someFolder, uikitFolder]

        waitForViewDidLoad()

        XCTAssertFalse(reactor.currentState.isAccordion)
        XCTAssertEqual(reactor.currentState.currentPath.last?.id, uikitFolder.id)
    }

    func test_리스트_모드_하위폴더로_이동() {
        createReactor()
        fetchLayoutOptionUseCase.option = .skip
        waitForViewDidLoad()

        reactor.action.onNext(.selectedFolder(id: MockFolder.rootFolders.first!.id))

        XCTAssertEqual(reactor.currentState.currentPath.last?.id, MockFolder.rootFolders.first!.id)
    }

    func test_리스트_모드_상위폴더로_이동() {
        createReactor()
        fetchLayoutOptionUseCase.option = .skip
        reactor.action.onNext(.viewDidLoad)
        reactor.action.onNext(.selectedFolder(id: MockFolder.someFolder.id))

        reactor.action.onNext(.backButtonTapped)

        XCTAssertTrue(reactor.currentState.currentPath.isEmpty)
    }

    func test_리스트_모드_선택_버튼_탭() {
        createReactor()
        fetchLayoutOptionUseCase.option = .skip
        waitForViewDidLoad()

        let targetFolder = MockFolder.rootFolders.first!
        let listExpectation = expectation(description: #function)

        reactor.state
            .map(\.currentPath)
            .filter { $0.last?.id == targetFolder.id }
            .take(1)
            .subscribe(onNext: { _ in
                listExpectation.fulfill()
            })
            .disposed(by: disposeBag)

        reactor.action.onNext(.selectedFolder(id: targetFolder.id))

        wait(for: [listExpectation], timeout: 1.0)

        let selectionExpectation = expectation(description: #function)
        var finalPhase: FolderSelectorReactor.State.Phase?

        reactor.pulse(\.$phase)
            .filter { if case .success = $0 { return true } else { return false } }
            .subscribe(onNext: { phase in
                finalPhase = phase
                selectionExpectation.fulfill()
            })
            .disposed(by: disposeBag)

        reactor.action.onNext(.selectButtonTapped)

        wait(for: [selectionExpectation], timeout: 1.0)
        if case .success(let selectedFolder) = finalPhase {
            XCTAssertEqual(selectedFolder?.id, targetFolder.id)
        } else {
            XCTFail()
        }
    }
}

extension FolderSelectorReactorTests {
    private func waitForViewDidLoad() {
        let expectation = expectation(description: #function)

        reactor.state
            .map(\.phase)
            .filter { $0 == .idle }
            .skip(1)
            .take(1)
            .subscribe(onNext: { _ in
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        reactor.action.onNext(.viewDidLoad)

        wait(for: [expectation], timeout: 1.0)
    }
}

extension FolderSelectorReactor.State.Phase: @retroactive Equatable {
    public static func == (lhs: FolderSelectorReactor.State.Phase, rhs: FolderSelectorReactor.State.Phase) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading):
            return true
        case (.success(let a), .success(let b)):
            return a?.id == b?.id
        case (.error(let a), .error(let b)):
            return a == b
        default:
            return false
        }
    }
}

private func matches(_ phase: FolderSelectorReactor.State.Phase?, _ expected: FolderSelectorReactor.State.Phase) -> Bool {
    guard let phase = phase else { return false }
    switch (phase, expected) {
    case (.idle, .idle), (.loading, .loading):
        return true
    case (.success, .success):
        return true
    case (.error, .error):
        return true
    default:
        return false
    }
}
