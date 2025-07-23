import XCTest
import RxSwift
@testable import Clipster

final class UnvisitedClipListReactorTests: XCTestCase {
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
