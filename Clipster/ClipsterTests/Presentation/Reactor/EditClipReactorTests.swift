import XCTest
import RxSwift
@testable import Clipster

final class EditClipReactorTests: XCTestCase {
    private var parseURLUseCase: ParseURLUseCase!
    private var fetchFolderUseCase: FetchFolderUseCase!
    private var createClipUseCase: CreateClipUseCase!
    private var updateClipUseCase: UpdateClipUseCase!
    private var disposeBag: DisposeBag!
    private var reactor: EditClipReactor!

    override func setUp() {
        super.setUp()
        parseURLUseCase = MockParseURLUseCase()
        fetchFolderUseCase = MockFetchFolderUseCase()
        createClipUseCase = MockCreateClipUseCase()
        updateClipUseCase = MockUpdateClipUseCase()
        disposeBag = DisposeBag()
        reactor = createReactor(type: .create)
    }

    override func tearDown() {
        super.tearDown()
        parseURLUseCase = nil
        fetchFolderUseCase = nil
        createClipUseCase = nil
        updateClipUseCase = nil
        disposeBag = nil
        reactor = nil
    }

    private func createReactor(
        type: EditClipReactor.EditClipReactorType
    ) -> EditClipReactor {
        switch type {
        case .create:
            return EditClipReactor(
                currentFolder: MockFolder.someFolder,
                parseURLUseCase: MockParseURLUseCase(),
                fetchFolderUseCase: MockFetchFolderUseCase(),
                createClipUseCase: MockCreateClipUseCase(),
                updateClipUseCase: MockUpdateClipUseCase()
            )
        case .edit:
            return EditClipReactor(
                clip: MockClip.someClip,
                parseURLUseCase: MockParseURLUseCase(),
                fetchFolderUseCase: MockFetchFolderUseCase(),
                createClipUseCase: MockCreateClipUseCase(),
                updateClipUseCase: MockUpdateClipUseCase()
            )
        }
    }

    func test_홈이나_폴더에서_클립_추가할_때_navigationTitle() {
        let reactor = createReactor(type: .create)
        XCTAssertEqual(reactor.currentState.navigationTitle, "클립 추가")
    }

    func test_클립_수정일_때_navigationTitle() {
        let reactor = createReactor(type: .edit)
        XCTAssertEqual(reactor.currentState.navigationTitle, "클립 수정")
    }
}
