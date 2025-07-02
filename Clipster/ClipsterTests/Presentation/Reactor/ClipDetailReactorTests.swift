import XCTest
import RxSwift
@testable import Clipster

final class ClipDetailReactorTests: XCTestCase {
    private var clip: Clip!
    private var fetchFolderUseCase: MockFetchFolderUseCase!
    private var deleteClipUseCase: MockDeleteClipUseCase!
    private var fetchClipUseCase: MockFetchClipUseCase!
    private var reactor: ClipDetailReactor!
    private var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        clip = MockClip.someClip
        fetchFolderUseCase = MockFetchFolderUseCase()
        deleteClipUseCase = MockDeleteClipUseCase()
        fetchClipUseCase = MockFetchClipUseCase()
        reactor = ClipDetailReactor(
            fetchFolderUseCase: fetchFolderUseCase,
            deleteClipUseCase: deleteClipUseCase,
            fetchClipUseCase: fetchClipUseCase,
            clip: clip
        )
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        super.tearDown()
        disposeBag = nil
        reactor = nil
        deleteClipUseCase = nil
        fetchClipUseCase = nil
        fetchFolderUseCase = nil
        clip = nil
    }

    func test_viewWillAppear_최초진입_성공() {
        let expectation = expectation(description: #function)
        var phaseResults: [ClipDetailReactor.State.Phase] = []
        fetchFolderUseCase.shouldSucceed = true

        reactor.pulse(\.$phase)
            .compactMap { $0 }
            .skip(1)
            .subscribe(onNext: { phase in
                phaseResults.append(phase)
                if phaseResults.count == 2 { expectation.fulfill() }
            })
            .disposed(by: disposeBag)

        reactor.action.onNext(.viewWillAppear)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(phaseResults, [.loading, .idle])
        XCTAssertTrue(fetchFolderUseCase.didCallExecute)
        XCTAssertFalse(fetchClipUseCase.didCallExecute)
    }

    func test_viewWillAppear_최초진입_실패() {
        let expectation = expectation(description: #function)
        var phaseResults: [ClipDetailReactor.State.Phase] = []
        fetchFolderUseCase.shouldSucceed = false

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

        reactor.action.onNext(.viewWillAppear)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(phaseResults.contains(where: { matches($0, .error("")) }))
        XCTAssertTrue(fetchFolderUseCase.didCallExecute)
    }

    func test_viewWillAppear_이후진입_성공() {
        let expectation = expectation(description: #function)
        reactor.action.onNext(.viewWillAppear)
        fetchClipUseCase.shouldSucceed = true
        fetchFolderUseCase.shouldSucceed = true

        reactor.pulse(\.$phase)
            .compactMap { $0 }
            .filter { $0 == .loading }
            .take(1)
            .subscribe(onNext: { _ in expectation.fulfill() })
            .disposed(by: disposeBag)

        reactor.action.onNext(.viewWillAppear)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(fetchClipUseCase.didCallExecute)
        XCTAssertTrue(fetchFolderUseCase.didCallExecute)
    }

    func test_viewWillAppear_이후진입_실패() {
        let expectation = expectation(description: #function)
        var phaseResults: [ClipDetailReactor.State.Phase] = []

        reactor.action.onNext(.viewWillAppear)
        fetchClipUseCase.shouldSucceed = false

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

        reactor.action.onNext(.viewWillAppear)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(phaseResults.contains(where: { matches($0, .error("")) }))
        XCTAssertTrue(fetchClipUseCase.didCallExecute)
    }

    func test_편집_버튼_탭() {
        let expectation = expectation(description: #function)
        var routeResult: ClipDetailReactor.State.Route?

        reactor.pulse(\.$route)
            .compactMap { $0 }
            .subscribe(onNext: { route in
                routeResult = route
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        reactor.action.onNext(.editButtonTapped)

        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(routeResult, .showEditClip(clip))
    }

    func test_삭제_버튼_탭() {
        let expectation = expectation(description: #function)
        var routeResult: ClipDetailReactor.State.Route?
        let expectedTitle = reactor.currentState.clipDisplay.urlMetadata.title

        reactor.pulse(\.$route)
            .compactMap { $0 }
            .subscribe(onNext: { route in
                routeResult = route
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        reactor.action.onNext(.deleteButtonTapped)

        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(routeResult, .showDeleteConfirmation(title: expectedTitle))
    }

    func test_삭제_확인_성공() {
        let expectation = expectation(description: #function)
        var phaseResults: [ClipDetailReactor.State.Phase] = []
        deleteClipUseCase.shouldSucceed = true

        reactor.pulse(\.$phase)
            .compactMap { $0 }
            .skip(1)
            .subscribe(onNext: { phase in
                phaseResults.append(phase)
                if phaseResults.count == 2 { expectation.fulfill() }
            })
            .disposed(by: disposeBag)

        reactor.action.onNext(.deleteConfirmed)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(phaseResults, [.loading, .success])
        XCTAssertTrue(deleteClipUseCase.didCallExecute)
    }

    func test_삭제_확인_실패() {
        let expectation = expectation(description: #function)
        var phaseResults: [ClipDetailReactor.State.Phase] = []
        deleteClipUseCase.shouldSucceed = false

        reactor.pulse(\.$phase)
            .compactMap { $0 }
            .skip(1)
            .subscribe(onNext: { phase in
                phaseResults.append(phase)
                if phaseResults.count == 2 { expectation.fulfill() }
            })
            .disposed(by: disposeBag)

        reactor.action.onNext(.deleteConfirmed)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(matches(phaseResults.first, .loading))
        XCTAssertTrue(matches(phaseResults.last, .error("")))
        XCTAssertTrue(deleteClipUseCase.didCallExecute)
    }
}

extension ClipDetailReactor.State.Phase: @retroactive Equatable {
    public static func == (lhs: ClipDetailReactor.State.Phase, rhs: ClipDetailReactor.State.Phase) -> Bool {
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

extension ClipDetailReactor.State.Route: @retroactive Equatable {
    public static func == (lhs: ClipDetailReactor.State.Route, rhs: ClipDetailReactor.State.Route) -> Bool {
        switch (lhs, rhs) {
        case (.showEditClip(let a), .showEditClip(let b)):
            return a.id == b.id
        case (.showDeleteConfirmation(let a), .showDeleteConfirmation(let b)):
            return a == b
        default:
            return false
        }
    }
}

private func matches(_ phase: ClipDetailReactor.State.Phase?, _ expected: ClipDetailReactor.State.Phase) -> Bool {
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
