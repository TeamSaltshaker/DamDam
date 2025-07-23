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

    func test_fetchFolder_성공() {
        let reactor = createReactor(type: .edit)
        let expectation = expectation(description: #function)

        reactor.state.map(\.currentFolder)
            .compactMap { $0 }
            .subscribe { folder in
                expectation.fulfill()
            }
            .disposed(by: disposeBag)

        reactor.action.onNext(.fetchInitialData)
        wait(for: [expectation], timeout: 1.0)

        XCTAssertNotNil(reactor.currentState.currentFolder)
        XCTAssertTrue(fetchFolderUseCase.didCallExecute)
    }

    func test_fetchFolder_실패() {
        let reactor = createReactor(type: .edit)
        let expectation = expectation(description: #function)

        reactor.state.map(\.currentFolder)
            .skip(1)
            .subscribe { folder in
                expectation.fulfill()
            }
            .disposed(by: disposeBag)

        fetchFolderUseCase.shouldSucceed = false

        reactor.action.onNext(.fetchInitialData)
        wait(for: [expectation], timeout: 1.0)

        XCTAssertNil(reactor.currentState.currentFolder)
        XCTAssertTrue(fetchFolderUseCase.didCallExecute)
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

    func test_클립_추가_시_saveClip_성공() {
        let reactor = EditClipReactor(
            type: .create,
            urlMetadataDisplay: MockURLMetadataDisplay.urlMetaDataDisplay,
            parseURLUseCase: parseURLUseCase,
            fetchFolderUseCase: fetchFolderUseCase,
            createClipUseCase: createClipUseCase,
            updateClipUseCase: updateClipUseCase
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

    func test_클립_추가_시_saveClip_실패() {
        let reactor = EditClipReactor(
            type: .create,
            urlMetadataDisplay: MockURLMetadataDisplay.urlMetaDataDisplay,
            parseURLUseCase: parseURLUseCase,
            fetchFolderUseCase: fetchFolderUseCase,
            createClipUseCase: createClipUseCase,
            updateClipUseCase: updateClipUseCase
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

    func test_클립_편집_시_saveClip_성공() {
        let reactor = EditClipReactor(
            type: .edit,
            clip: MockClip.someClip,
            urlMetadataDisplay: MockURLMetadataDisplay.urlMetaDataDisplay,
            parseURLUseCase: parseURLUseCase,
            fetchFolderUseCase: fetchFolderUseCase,
            createClipUseCase: createClipUseCase,
            updateClipUseCase: updateClipUseCase
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
        XCTAssertTrue(updateClipUseCase.didCallExecute)
        XCTAssertNotNil(updateClipUseCase.receivedClip)
    }

    func test_클립_편집_시_saveClip_실패() {
        let reactor = EditClipReactor(
            type: .edit,
            clip: MockClip.someClip,
            urlMetadataDisplay: MockURLMetadataDisplay.urlMetaDataDisplay,
            parseURLUseCase: parseURLUseCase,
            fetchFolderUseCase: fetchFolderUseCase,
            createClipUseCase: createClipUseCase,
            updateClipUseCase: updateClipUseCase
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

        updateClipUseCase.shouldSucceed = false
        reactor.action.onNext(.saveClip)

        wait(for: [expectation], timeout: 1.0)

        XCTAssertFalse(reactor.currentState.isSuccessedEditClip)
        XCTAssertTrue(updateClipUseCase.didCallExecute)
        XCTAssertNotNil(updateClipUseCase.receivedClip)
    }

    func test_disappearFolderSelectorView() {
        reactor.action.onNext(.tapFolderView)
        XCTAssertTrue(reactor.currentState.isTappedFolderView)

        reactor.action.onNext(.disappearFolderSelectorView)
        XCTAssertFalse(reactor.currentState.isTappedFolderView)
    }

    func test_섬네일_이미지와_스크린샷_없을_때_isHiddenURLMetadataStackView_true() {
        let state = EditClipReactor.State(
            type: .create,
            urlMetadataDisplay: MockURLMetadataDisplay.urlMetadataDisplayWithoutThumbnailAndScreenshot
        )

        XCTAssertTrue(state.isHiddenURLMetadataStackView)
    }

    func test_섬네일_이미지_있을_때_isHiddenURLMetadataStackView_false() {
        let state = EditClipReactor.State(
            type: .create,
            urlMetadataDisplay: MockURLMetadataDisplay.urlMetadataDisplayWithThumbnail
        )

        XCTAssertFalse(state.isHiddenURLMetadataStackView)
    }

    func test_스크린샷_있을_때_isHiddenURLMetadataStackView_false() {
        let state = EditClipReactor.State(
            type: .create,
            urlMetadataDisplay: MockURLMetadataDisplay.urlMetadataDisplayWithScreenshot
        )

        XCTAssertFalse(state.isHiddenURLMetadataStackView)
    }

    func test_urlValidationResult_valid일_때_urlTextFieldBorderColor() {
        let state = EditClipReactor.State(
            type: .create,
            urlString: "테스트",
            urlValidationResult: .valid
        )

        XCTAssertEqual(state.urlTextFieldBorderColor, .appPrimary)
    }

    func test_urlValidationResult_validWithWarning일_때_urlTextFieldBorderColor() {
        let state = EditClipReactor.State(
            type: .create,
            urlString: "테스트",
            urlValidationResult: .validWithWarning
        )

        XCTAssertEqual(state.urlTextFieldBorderColor, .yellow600)
    }

    func test_urlValidationResult_invalid일_때_urlTextFieldBorderColor() {
        let state = EditClipReactor.State(
            type: .create,
            urlString: "테스트",
            urlValidationResult: .invalid
        )

        XCTAssertEqual(state.urlTextFieldBorderColor, .red600)
    }
    
    func test_urlValidationResult_valid일_때_urlValidationLabelText() {
        let state = EditClipReactor.State(
            type: .create,
            urlValidationResult: .valid
        )

        XCTAssertEqual(state.urlValidationLabelText, "올바른 URL 입니다.")
    }

    func test_urlValidationResult_validWithWarning일_때_urlValidationLabelText() {
        let state = EditClipReactor.State(
            type: .create,
            urlValidationResult: .validWithWarning
        )

        XCTAssertEqual(state.urlValidationLabelText, "올바른 URL이지만, 미리보기를 불러 올 수 없습니다.")
    }

    func test_urlValidationResult_invalid일_때_urlValidationLabelText() {
        let state = EditClipReactor.State(
            type: .create,
            urlValidationResult: .invalid
        )

        XCTAssertEqual(state.urlValidationLabelText, "올바르지 않은 URL 입니다.")
    }

    func test_urlValidationResult_valid일_때_urlValidationImageResource() {
        let state = EditClipReactor.State(
            type: .create,
            urlValidationResult: .valid
        )

        XCTAssertEqual(state.urlValidationImageResource, .checkBlue)
    }

    func test_urlValidationResult_validWithWarning일_때_urlValidationImageResource() {
        let state = EditClipReactor.State(
            type: .create,
            urlValidationResult: .validWithWarning
        )

        XCTAssertEqual(state.urlValidationImageResource, .infoYellow)
    }

    func test_urlValidationResult_invalid일_때_urlValidationImageResource() {
        let state = EditClipReactor.State(
            type: .create,
            urlValidationResult: .invalid
        )

        XCTAssertEqual(state.urlValidationImageResource, .xCircleRed)
    }
}
