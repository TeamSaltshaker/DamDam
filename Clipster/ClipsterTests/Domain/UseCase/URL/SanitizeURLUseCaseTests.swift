import XCTest
@testable import Clipster

final class SanitizeURLUseCaseTests: XCTestCase {
    private var useCase: SanitizeURLUseCase!

    override func setUp() {
        super.setUp()
        useCase = DefaultSanitizeURLUseCase()
    }

    override func tearDown() {
        useCase = nil
        super.tearDown()
    }

    func test_prefix로_http가_없을_때_성공() {
        let input = "naver.com"
        let result = useCase.execute(urlString: input)


        switch result {
        case .success(let url):
            XCTAssertNotNil(url)
        case .failure:
            XCTFail("sanitizeURL 실패 input: \(input)")
        }
    }

    func test_prefix로_http가_입력_됐을_때_성공() {
        let input = "httpnaver.com"
        let result = useCase.execute(urlString: input)

        switch result {
        case .success(let url):
            XCTAssertNotNil(url)
        case .failure:
            XCTFail("sanitizeURL 실패 input: \(input)")
        }
    }

    func test_prefix로_https가_입력_됐을_때_성공() {
        let input = "httpsnaver.com"
        let result = useCase.execute(urlString: input)

        switch result {
        case .success(let url):
            XCTAssertNotNil(url)
        case .failure:
            XCTFail("sanitizeURL 실패 input: \(input)")
        }
    }

    func test_prefix로_http_세미콜론이_입력_됐을_때_성공() {
        let input = "http:naver.com"
        let result = useCase.execute(urlString: input)

        switch result {
        case .success(let url):
            XCTAssertNotNil(url)
        case .failure:
            XCTFail("sanitizeURL 실패 input: \(input)")
        }
    }

    func test_prefix로_https_세미콜론이_입력_됐을_때_성공() {
        let input = "https:naver.com"
        let result = useCase.execute(urlString: input)

        switch result {
        case .success(let url):
            XCTAssertNotNil(url)
        case .failure:
            XCTFail("sanitizeURL 실패 input: \(input)")
        }
    }

    func test_prefix로_http_세미콜론_슬래쉬가_입력_됐을_때_성공() {
        let input = "http:/naver.com"
        let result = useCase.execute(urlString: input)

        switch result {
        case .success(let url):
            XCTAssertNotNil(url)
        case .failure:
            XCTFail("sanitizeURL 실패 input: \(input)")
        }
    }


    func test_prefix로_https_세미콜론_슬래쉬가_입력_됐을_때_성공() {
        let input = "https:/naver.com"
        let result = useCase.execute(urlString: input)

        switch result {
        case .success(let url):
            XCTAssertNotNil(url)
        case .failure:
            XCTFail("sanitizeURL 실패 input: \(input)")
        }
    }

    func test_prefix로_http_세미콜론_슬래쉬_슬래쉬가_입력_됐을_때_성공() {
        let input = "http://naver.com"
        let result = useCase.execute(urlString: input)

        switch result {
        case .success(let url):
            XCTAssertNotNil(url)
        case .failure:
            XCTFail("sanitizeURL 실패 input: \(input)")
        }
    }


    func test_prefix로_https_세미콜론_슬래쉬_슬래쉬가_입력_됐을_때_성공() {
        let input = "https://naver.com"
        let result = useCase.execute(urlString: input)

        switch result {
        case .success(let url):
            XCTAssertNotNil(url)
        case .failure:
            XCTFail("sanitizeURL 실패 input: \(input)")
        }
    }

    func test_prefix로_https_세미콜론_슬래쉬_슬래쉬_슬래쉬가_입력_됐을_때_실패() {
        let input = "https:///naver.com"
        let result = useCase.execute(urlString: input)

        switch result {
        case .success:
            XCTFail("sanitizeURL 실패 input: \(input)")
        case .failure(let error):
            XCTAssertEqual(error, .badURL)
        }
    }

    func test_URL타입이_아닌_형식이_입력_될_때_실패() {
        let input = "abcd"
        let result = useCase.execute(urlString: input)

        switch result {
        case .success:
            XCTFail("sanitizeURL 실패 input: \(input)")
        case .failure(let error):
            XCTAssertEqual(error, .badURL)
        }
    }

    func test_콜론이_포함되었을_때_성공() {
        let input = "abcd.efg"
        let result = useCase.execute(urlString: input)

        switch result {
        case .success(let url):
            XCTAssertNotNil(url)
        case .failure:
            XCTFail("sanitizeURL 실패 input: \(input)")
        }
    }
}
