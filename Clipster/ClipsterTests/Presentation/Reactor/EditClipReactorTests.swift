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

    func test_viewDidAppear() {
        reactor.action.onNext(.viewDidAppear)
        XCTAssertEqual(reactor.currentState.shouldReadPastedboardURL, true)
    }

    func test_url_입력했을_때_공백_제거() {
        reactor.action.onNext(.editURLTextField(" https://google.com "))
        XCTAssertEqual(reactor.currentState.urlString, "https://google.com")
    }

    func test_url_빈_문자열_일_때_() {
        reactor.action.onNext(.editURLTextField("https://google.com"))
        reactor.action.onNext(.editURLTextField(""))

        XCTAssertEqual(reactor.currentState.urlString, "")
        XCTAssertTrue(reactor.currentState.isHiddenURLValidationStackView)
    }
}
