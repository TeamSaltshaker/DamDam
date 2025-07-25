import XCTest
import RxSwift
@testable import Clipster

final class ShareReactorTests: XCTestCase {
    private var parseURLUseCase: MockParseURLUseCase!
    private var createClipUseCase: MockCreateClipUseCase!
    private var extractExtensionContextUseCase: MockExtractExtensionContextUseCase!
    private var disposeBag: DisposeBag!
    private var reactor: ShareReactor!

    override func setUp() {
        super.setUp()
        parseURLUseCase = MockParseURLUseCase()
        createClipUseCase = MockCreateClipUseCase()
        extractExtensionContextUseCase = MockExtractExtensionContextUseCase()
        disposeBag = DisposeBag()
        reactor = ShareReactor(
            parseURLUseCase: parseURLUseCase,
            createClipUseCase: createClipUseCase,
            extractExtensionContextUseCase: extractExtensionContextUseCase
        )
    }

    override func tearDown() {
        super.tearDown()
        parseURLUseCase = nil
        createClipUseCase = nil
        extractExtensionContextUseCase = nil
        disposeBag = nil
        reactor = nil
    }

    func test_viewWillAppear() {
        reactor.action.onNext(.viewWillAppear)

        XCTAssertTrue(reactor.currentState.isReadyToExtractURL)
    }

    func test_extractedExtensionItems() {
        let expectation = expectation(description: #function)

        reactor.state.map(\.urlString)
            .skip(1)
            .subscribe { result in
                expectation.fulfill()
            }
            .disposed(by: disposeBag)


        extractExtensionContextUseCase.executeResult = .success(URL(string: "https://google.com")!)

        reactor.action.onNext(.extractedExtensionItems([NSExtensionItem()]))
        wait(for: [expectation], timeout: 1.0)

        XCTAssertEqual(reactor.currentState.urlString, "https://google.com")
        XCTAssertTrue(extractExtensionContextUseCase.didCallExecute)
        XCTAssertNotNil(extractExtensionContextUseCase.receivedExtensionItems)
    }

    func test_editURLTextField() {
        let text = "   https://google.com   "
        reactor.action.onNext(.editURLTextField(text))

        XCTAssertEqual(reactor.currentState.urlString, "https://google.com")
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

    func test_editingURLTextField() {
        reactor.action.onNext(.editingURLTextField)

        XCTAssertTrue(reactor.currentState.isLoading)
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

    func test_editFolder() {
        let mockFolder = MockFolder.someFolder

        reactor.action.onNext(.changeFolder(mockFolder))

        XCTAssertNotNil(reactor.currentState.currentFolder)
        XCTAssertEqual(reactor.currentState.currentFolder?.id, mockFolder.id)
    }

    func test_saveClip_성공() {
        let reactor = ShareReactor(
            urlMetadataDisplay: MockURLMetadataDisplay.urlMetaDataDisplay,
            parseURLUseCase: parseURLUseCase,
            createClipUseCase: createClipUseCase,
            extractExtensionContextUseCase: extractExtensionContextUseCase
        )

        let expectation = expectation(description: #function)

        reactor.state.map(\.isSuccessedEditClip)
            .filter { $0 }
            .subscribe(onNext: { result in
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        reactor.action.onNext(.saveClip)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(reactor.currentState.isSuccessedEditClip)
        XCTAssertTrue(createClipUseCase.didCallExecute)
        XCTAssertNotNil(createClipUseCase.receivedClip)
    }

    func test_saveClip_실패() {
        let reactor = ShareReactor(
            urlMetadataDisplay: MockURLMetadataDisplay.urlMetaDataDisplay,
            parseURLUseCase: parseURLUseCase,
            createClipUseCase: createClipUseCase,
            extractExtensionContextUseCase: extractExtensionContextUseCase
        )

        let expectation = expectation(description: #function)

        reactor.state.map(\.isSuccessedEditClip)
            .skip(1)
            .subscribe(onNext: { result in
                if !result {
                    expectation.fulfill()
                }
            })
            .disposed(by: disposeBag)

        createClipUseCase.shouldSucceed = false
        reactor.action.onNext(.saveClip)
        wait(for: [expectation], timeout: 1.0)

        XCTAssertFalse(reactor.currentState.isSuccessedEditClip)
        XCTAssertTrue(createClipUseCase.didCallExecute)
        XCTAssertNotNil(createClipUseCase.receivedClip)
    }
}
