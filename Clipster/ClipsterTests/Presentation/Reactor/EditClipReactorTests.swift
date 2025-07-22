import XCTest
import RxSwift
@testable import Clipster

final class EditClipReactorTests: XCTestCase {
    private var parseURLUseCase: MockParseURLUseCase!
    private var fetchFolderUseCase: MockFetchFolderUseCase!
    private var createClipUseCase: MockCreateClipUseCase!
    private var updateClipUseCase: MockUpdateClipUseCase!
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
                parseURLUseCase: parseURLUseCase,
                fetchFolderUseCase: fetchFolderUseCase,
                createClipUseCase: createClipUseCase,
                updateClipUseCase: updateClipUseCase
            )
        case .edit:
            return EditClipReactor(
                clip: MockClip.someClip,
                parseURLUseCase: parseURLUseCase,
                fetchFolderUseCase: fetchFolderUseCase,
                createClipUseCase: createClipUseCase,
                updateClipUseCase: updateClipUseCase
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

    func test_valid_URL_유효성_검증(){
        let expectation = expectation(description: #function)

        reactor.state.map(\.urlValidationResult)
            .compactMap { $0 }
            .filter { $0 == .valid }
            .subscribe(onNext: { result in
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        reactor.action.onNext(.editingURLTextField)
        parseURLUseCase.executeResult = .success((MockURLMetadata.urlMetadata, true))

        reactor.action.onNext(.validifyURL("https://google.com"))

        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(parseURLUseCase.didCallExecute)
        XCTAssertEqual(parseURLUseCase.receivedURLString, "https://google.com")
        XCTAssertTrue(reactor.currentState.isURLValid)
        XCTAssertEqual(reactor.currentState.urlValidationResult, .valid)
        XCTAssertFalse(reactor.currentState.isLoading)
    }

    func test_validWithWarning_URL_유효성_검증(){
        let expectation = expectation(description: #function)

        reactor.state.map(\.urlValidationResult)
            .compactMap { $0 }
            .filter { $0 == .validWithWarning }
            .subscribe(onNext: { result in
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        reactor.action.onNext(.editingURLTextField)
        parseURLUseCase.executeResult = .success((nil, true))

        reactor.action.onNext(.validifyURL("https://a.a"))

        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(parseURLUseCase.didCallExecute)
        XCTAssertEqual(parseURLUseCase.receivedURLString, "https://a.a")
        XCTAssertTrue(reactor.currentState.isURLValid)
        XCTAssertEqual(reactor.currentState.urlValidationResult, .validWithWarning)
        XCTAssertFalse(reactor.currentState.isLoading)
    }

    func test_invalid_URL_유효성_검증(){
        let expectation = expectation(description: #function)

        reactor.state.map(\.urlValidationResult)
            .compactMap { $0 }
            .filter { $0 == .invalid }
            .subscribe(onNext: { result in
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        reactor.action.onNext(.editingURLTextField)
        parseURLUseCase.executeResult = .success((nil, false))

        reactor.action.onNext(.validifyURL("aaa"))

        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(parseURLUseCase.didCallExecute)
        XCTAssertEqual(parseURLUseCase.receivedURLString, "aaa")
        XCTAssertFalse(reactor.currentState.isURLValid)
        XCTAssertEqual(reactor.currentState.urlValidationResult, .invalid)
        XCTAssertFalse(reactor.currentState.isLoading)
    }

    func test_editingURLTextField_isLoading이_true() {
        reactor.action.onNext(.editingURLTextField)

        XCTAssertTrue(reactor.currentState.isLoading)
        XCTAssertEqual(reactor.currentState.urlValidationLabelText, "URL 분석 중...")
    }

    func test_editMemo() {
        reactor.action.onNext(.editMemo(" 메모 테스트 "))

        XCTAssertEqual(reactor.currentState.memoText, "메모 테스트")
        XCTAssertEqual(reactor.currentState.memoLimit, "6 / 100")
    }

    func test_tapFolderView() {
        reactor.action.onNext(.tapFolderView)

        XCTAssertTrue(reactor.currentState.isTappedFolderView)
    }

    func test_changeFolder시_currentFolder_정상_반영() {
        let mockFolder = MockFolder.someFolder

        reactor.action.onNext(.changeFolder(mockFolder))

        XCTAssertNotNil(reactor.currentState.currentFolder)
        XCTAssertEqual(reactor.currentState.currentFolder?.id, mockFolder.id)
    }
}
