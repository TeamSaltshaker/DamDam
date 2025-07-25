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
}
