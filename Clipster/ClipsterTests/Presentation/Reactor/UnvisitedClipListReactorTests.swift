import XCTest
import RxSwift
@testable import Clipster

final class UnvisitedClipListReactorTests: XCTestCase {
    typealias Phase = UnvisitedClipListReactor.State.Phase
    typealias Route = UnvisitedClipListReactor.State.Route

    private var disposeBag: DisposeBag!

    private var clips: [Clip] = []
    private var fetchUnvisitedClipsUseCase: MockFetchUnvisitedClipsUseCase!
    private var deleteClipUseCase: MockDeleteClipUseCase!
    private var visitClipUseCase: MockVisitClipUseCase!

    private var reactor: UnvisitedClipListReactor!

    private let clipIndex = 0

    override func setUp() {
        disposeBag = DisposeBag()

        clips = [MockClip.someClip]
        fetchUnvisitedClipsUseCase = MockFetchUnvisitedClipsUseCase()
        deleteClipUseCase = MockDeleteClipUseCase()
        visitClipUseCase = MockVisitClipUseCase()

        reactor = UnvisitedClipListReactor(
            clips: clips,
            fetchUnvisitedClipsUseCase: fetchUnvisitedClipsUseCase,
            deleteClipUseCase: deleteClipUseCase,
            visitClipUseCase: visitClipUseCase
        )
    }

    override func tearDown() {
        disposeBag = nil
        clips = []
        fetchUnvisitedClipsUseCase = nil
        deleteClipUseCase = nil
        visitClipUseCase = nil
        reactor = nil
    }

    func test_화면_첫_진입시_초기_클립_사용() {
        // given
        let expectation = expectation(description: #function)
        var phaseResults: [Phase] = []

        reactor.pulse(\.$phase)
            .skip(1)
            .subscribe { phase in
                phaseResults.append(phase)
                if phase == .success {
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        // when
        reactor.action.onNext(.viewWillAppear)

        // then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(phaseResults, [.loading, .success])
        XCTAssertFalse(fetchUnvisitedClipsUseCase.didCallExecute)
        XCTAssertEqual(reactor.currentState.clips.count, clips.count)
    }

    func test_화면_첫_진입이_아닐시_클립_불러오기() {
        // given
        let expectation = expectation(description: #function)
        var phaseResults: [Phase] = []

        reactor.action.onNext(.viewWillAppear)
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))

        reactor.pulse(\.$phase)
            .skip(1)
            .subscribe { phase in
                phaseResults.append(phase)
                if phase == .success {
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        // when
        reactor.action.onNext(.viewWillAppear)

        // then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(phaseResults, [.loading, .success])
        XCTAssertTrue(fetchUnvisitedClipsUseCase.didCallExecute)
        XCTAssertEqual(reactor.currentState.clips.count, MockClip.unsortedClips.count)
    }

    func test_화면_첫_진입이_아닐시_클립_불러오기_실패() {
        // given
        let expectation = expectation(description: #function)
        var phaseResults: [Phase] = []
        fetchUnvisitedClipsUseCase.shouldSucceed = false

        reactor.action.onNext(.viewWillAppear)
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))

        reactor.pulse(\.$phase)
            .skip(1)
            .subscribe { phase in
                phaseResults.append(phase)
                if phase == .error("") {
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        // when
        reactor.action.onNext(.viewWillAppear)

        // then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(phaseResults, [.loading, .error("")])
        XCTAssertTrue(fetchUnvisitedClipsUseCase.didCallExecute)
    }

    func test_뒤로가기_버튼_탭() {
        // given
        let expectation = expectation(description: #function)
        var routeResult: Route?

        reactor.pulse(\.$route)
            .compactMap { $0 }
            .subscribe { route in
                routeResult = route
                expectation.fulfill()
            }
            .disposed(by: disposeBag)

        // when
        reactor.action.onNext(.tapBack)

        // then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(routeResult, .back)
    }

    func test_클립_셀_탭() {
        // given
        let expectation = expectation(description: #function)
        var routeResult: Route?

        reactor.pulse(\.$route)
            .compactMap { $0 }
            .subscribe { route in
                routeResult = route
                expectation.fulfill()
            }
            .disposed(by: disposeBag)

        // when
        reactor.action.onNext(.tapCell(clipIndex))

        // then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(routeResult, .showWebView(MockClip.someClip.url))
        XCTAssertTrue(visitClipUseCase.didCallExecute)
    }

    func test_클립_상세정보_탭() {
        // given
        let expectation = expectation(description: #function)
        var routeResult: Route?

        reactor.pulse(\.$route)
            .compactMap { $0 }
            .subscribe { route in
                routeResult = route
                expectation.fulfill()
            }
            .disposed(by: disposeBag)

        // when
        reactor.action.onNext(.tapDetail(clipIndex))

        // then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(routeResult, .showDetailClip(MockClip.someClip))
    }

    func test_클립_편집_탭() {
        // given
        let expectation = expectation(description: #function)
        var routeResult: Route?

        reactor.pulse(\.$route)
            .compactMap { $0 }
            .subscribe { route in
                routeResult = route
                expectation.fulfill()
            }
            .disposed(by: disposeBag)

        // when
        reactor.action.onNext(.tapDetail(clipIndex))

        // then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(routeResult, .showDetailClip(MockClip.someClip))
    }

    func test_클립_삭제_탭() {
        // given
        let expectation = expectation(description: #function)
        var phaseResults: [Phase] = []

        reactor.pulse(\.$phase)
            .compactMap { $0 }
            .skip(1)
            .subscribe { phase in
                phaseResults.append(phase)
                if phase == .success {
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        // when
        reactor.action.onNext(.tapDelete(clipIndex))

        // then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(phaseResults, [.loading, .success])
        XCTAssertTrue(deleteClipUseCase.didCallExecute)
        XCTAssertTrue(fetchUnvisitedClipsUseCase.didCallExecute)
        XCTAssertEqual(reactor.currentState.clips.count, MockClip.unvisitedClips.count)
    }

    func test_클립_삭제_탭_실패() {
        // given
        let expectation = expectation(description: #function)
        var phaseResults: [Phase] = []
        deleteClipUseCase.shouldSucceed = false

        reactor.pulse(\.$phase)
            .compactMap { $0 }
            .skip(1)
            .subscribe { phase in
                phaseResults.append(phase)
                if phase == .error("") {
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        // when
        reactor.action.onNext(.tapDelete(clipIndex))

        // then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(phaseResults, [.loading, .error("")])
        XCTAssertTrue(deleteClipUseCase.didCallExecute)
        XCTAssertFalse(fetchUnvisitedClipsUseCase.didCallExecute)
    }
}

extension UnvisitedClipListReactor.State.Phase: @retroactive Equatable {
    public static func == (
        lhs: UnvisitedClipListReactor.State.Phase,
        rhs: UnvisitedClipListReactor.State.Phase
    ) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.success, .success), (.error, .error):
            return true
        default:
            return false
        }
    }
}

extension UnvisitedClipListReactor.State.Route: @retroactive Equatable {
    public static func == (
        lhs: UnvisitedClipListReactor.State.Route,
        rhs: UnvisitedClipListReactor.State.Route
    ) -> Bool {
        switch (lhs, rhs) {
        case (.back, .back):
            return true
        case (.showWebView(let a), .showWebView(let b)):
            return a == b
        case (.showDetailClip(let a), .showDetailClip(let b)):
            return a.id == b.id
        case (.showEditClip(let a), .showEditClip(let b)):
            return a.id == b.id
        default:
            return false
        }
    }
}
