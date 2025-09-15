import XCTest
@testable import Clipster

final class ExtractURLUseCaseTests: XCTestCase {
    private var useCase: DefaultExtractURLUseCase!
    private var pasteboardRepository: StubPasteboardRepository!

    override func setUp() {
        super.setUp()
        pasteboardRepository = StubPasteboardRepository()
        useCase = DefaultExtractURLUseCase(
            pasteboardRepository: pasteboardRepository
        )
    }

    override func tearDown() {
        pasteboardRepository = nil
        useCase = nil
        super.tearDown()
    }

    func test_클립보드에_텍스트와_URL이_있을_때_성공() async {
        let urlString = "https://www.google.com"
        let pastedString = "현재 URL은 \(urlString) 입니다."

        let expectedURL = URL(string: urlString)!

        pasteboardRepository.fetchURLStringResult = .success(pastedString)
        
        let result = await useCase.execute()

        switch result {
        case .success(let extractedURL):
            XCTAssertEqual(extractedURL, expectedURL)
        case .failure(let error):
            XCTFail("성공해야 하는 케이스입니다. \(error)")
        }
    }

    func test_클립보드에_감지된_내용이_없을_때_실패() async {
        pasteboardRepository.fetchURLStringResult = .failure(.notDetectedURL)

        let result = await useCase.execute()

        switch result {
        case .success:
            XCTFail("실패해야 하는 케이스입니다.")
        case .failure(let error):
            XCTAssertEqual(error, .notDetectedURL)
        }
    }

    func test_클립보드의_내용을_가져올_수_없을_때_실패() async {
        pasteboardRepository.fetchURLStringResult = .failure(.failedToRead)

        let result = await useCase.execute()

        switch result {
        case .success:
            XCTFail("실패해야 하는 케이스입니다.")
        case .failure(let error):
            XCTAssertEqual(error, .failedToRead)
        }
    }

    func test_URL_추출_중_오류_발생_시_실패() async {
        pasteboardRepository.fetchURLStringResult = .success("asdfasdf")

        let result = await useCase.execute()

        switch result {
        case .success:
            XCTFail("실패해야 하는 케이스입니다.")
        case .failure(let error):
            XCTAssertEqual(error, .failedExtractURL)
        }
    }
}
