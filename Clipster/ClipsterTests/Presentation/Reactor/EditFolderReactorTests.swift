import XCTest
import RxSwift
@testable import Clipster

final class EditFolderReactorTests: XCTestCase {
    private var canSaveFolderUseCase: MockCanSaveFolderUseCase!
    private var sanitizeFolderTitleUseCase: MockSanitizeFolderTitleUseCase!
    private var createFolderUseCase: MockCreateFolderUseCase!
    private var updateFolderUseCase: MockUpdateFolderUseCase!
    private var disposeBag: DisposeBag!
    private var reactor: EditFolderReactor!

    override func setUp() {
        super.setUp()
        self.canSaveFolderUseCase = MockCanSaveFolderUseCase()
        self.sanitizeFolderTitleUseCase = MockSanitizeFolderTitleUseCase()
        self.createFolderUseCase = MockCreateFolderUseCase()
        self.updateFolderUseCase = MockUpdateFolderUseCase()
        self.disposeBag = DisposeBag()
    }

    override func tearDown() {
        self.reactor = nil
        self.canSaveFolderUseCase = nil
        self.sanitizeFolderTitleUseCase = nil
        self.createFolderUseCase = nil
        self.updateFolderUseCase = nil
        self.disposeBag = nil
        super.tearDown()
    }

    private func createReactor(folder: Folder? = nil, parentFolder: Folder? = nil) {
        self.reactor = EditFolderReactor(
            canSaveFolderUseCase: canSaveFolderUseCase,
            sanitizeFolderTitleUseCase: sanitizeFolderTitleUseCase,
            createFolderUseCase: createFolderUseCase,
            updateFolderUseCase: updateFolderUseCase,
            parentFolder: parentFolder,
            folder: folder
        )
    }

    func test_네비게이션_타이틀_설정() {
        createReactor(folder: nil)
        XCTAssertEqual(reactor.currentState.navigationTitle, "폴더 추가")

        createReactor(folder: MockFolder.folderToEdit)
        XCTAssertEqual(reactor.currentState.navigationTitle, "폴더 편집")
    }

    func test_뷰_나타났을때_키보드_표시() {
        createReactor()
        let expectation = expectation(description: #function)

        reactor.state.map(\.isShowKeyboard)
            .filter { $0 == true }
            .take(1)
            .subscribe(onNext: { _ in
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        reactor.action.onNext(.viewDidAppear)

        waitForExpectations(timeout: 1.0)
        XCTAssertTrue(reactor.currentState.isShowKeyboard)
    }

    func test_폴더_제목_변경() {
        createReactor()
        let newTitle = "새로운 폴더"

        reactor.action.onNext(.folderTitleChanged(newTitle))

        XCTAssertEqual(reactor.currentState.folderTitle, newTitle)
        XCTAssertTrue(reactor.currentState.isSavable)
        XCTAssertTrue(canSaveFolderUseCase.didCallExecute)
        XCTAssertTrue(sanitizeFolderTitleUseCase.didCallExecute)
    }

    func test_저장_버튼_탭_추가_성공() {
        createReactor(folder: nil)
        reactor.action.onNext(.folderTitleChanged("저장될 폴더"))
        createFolderUseCase.shouldSucceed = true

        let expectation = expectation(description: #function)
        var phaseResults: [EditFolderReactor.State.Phase] = []

        reactor.pulse(\.$phase)
            .compactMap { $0 }
            .skip(1)
            .subscribe(onNext: { phase in
                phaseResults.append(phase)
                if phaseResults.count == 2 { expectation.fulfill() }
            })
            .disposed(by: disposeBag)

        reactor.action.onNext(.saveButtonTapped)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(matches(phaseResults.first, .loading))
        XCTAssertTrue(matches(phaseResults.last, .success(folder: MockFolder.folderToEdit)))
        XCTAssertTrue(createFolderUseCase.didCallExecute)
        XCTAssertFalse(updateFolderUseCase.didCallExecute)
    }

    func test_저장_버튼_탭_추가_실패() {
        createReactor(folder: nil)
        reactor.action.onNext(.folderTitleChanged("저장될 폴더"))
        createFolderUseCase.shouldSucceed = false

        let expectation = expectation(description: #function)
        var phaseResults: [EditFolderReactor.State.Phase] = []

        reactor.pulse(\.$phase)
            .compactMap { $0 }
            .skip(1)
            .subscribe(onNext: { phase in
                phaseResults.append(phase)
                if matches(phase, .error("")) {
                    expectation.fulfill()
                }
            })
            .disposed(by: disposeBag)

        reactor.action.onNext(.saveButtonTapped)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(phaseResults.contains(where: { matches($0, .error("")) }))
        XCTAssertTrue(createFolderUseCase.didCallExecute)
    }

    func test_저장_버튼_탭_편집_성공() {
        createReactor(folder: MockFolder.folderToEdit)
        updateFolderUseCase.shouldSucceed = true

        let expectation = expectation(description: #function)
        var phaseResults: [EditFolderReactor.State.Phase] = []

        reactor.pulse(\.$phase)
            .compactMap { $0 }
            .skip(1)
            .subscribe(onNext: { phase in
                phaseResults.append(phase)
                if phaseResults.count == 2 { expectation.fulfill() }
            })
            .disposed(by: disposeBag)

        reactor.action.onNext(.saveButtonTapped)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(matches(phaseResults.first, .loading))
        XCTAssertTrue(matches(phaseResults.last, .success(folder: MockFolder.folderToEdit)))
        XCTAssertTrue(updateFolderUseCase.didCallExecute)
        XCTAssertFalse(createFolderUseCase.didCallExecute)
    }

    func test_저장_버튼_탭_편집_실패() {
        createReactor(folder: MockFolder.folderToEdit)
        updateFolderUseCase.shouldSucceed = false

        let expectation = expectation(description: #function)
        var phaseResults: [EditFolderReactor.State.Phase] = []

        reactor.pulse(\.$phase)
            .compactMap { $0 }
            .skip(1)
            .subscribe(onNext: { phase in
                phaseResults.append(phase)
                if matches(phase, .error("")) {
                    expectation.fulfill()
                }
            })
            .disposed(by: disposeBag)

        reactor.action.onNext(.saveButtonTapped)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(phaseResults.contains(where: { matches($0, .error("")) }))
        XCTAssertTrue(updateFolderUseCase.didCallExecute)
    }

    func test_상위_폴더_선택_버튼_탭() {
        createReactor()
        let expectation = expectation(description: #function)
        var routeResult: EditFolderReactor.State.Route?

        reactor.pulse(\.$route)
            .compactMap { $0 }
            .subscribe(onNext: { route in
                routeResult = route
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        reactor.action.onNext(.folderViewTapped)

        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(routeResult, .showFolderSelector)
    }
}

extension EditFolderReactor.State.Phase: @retroactive Equatable {
    public static func == (lhs: EditFolderReactor.State.Phase, rhs: EditFolderReactor.State.Phase) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading):
            return true
        case (.success(let a), .success(let b)):
            return a.id == b.id
        case (.error(let a), .error(let b)):
            return a == b
        default:
            return false
        }
    }
}

extension EditFolderReactor.State.Route {
    public static func == (lhs: EditFolderReactor.State.Route, rhs: EditFolderReactor.State.Route) -> Bool {
        switch (lhs, rhs) {
        case (.showFolderSelector, .showFolderSelector):
            return true
        }
    }
}

private func matches(_ phase: EditFolderReactor.State.Phase?, _ expected: EditFolderReactor.State.Phase) -> Bool {
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
