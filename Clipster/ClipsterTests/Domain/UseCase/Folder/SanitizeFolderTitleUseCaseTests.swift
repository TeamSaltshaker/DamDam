import XCTest
@testable import Clipster

final class SanitizeFolderTitleUseCaseTests: XCTestCase {
    private var useCase: SanitizeFolderTitleUseCase!

    override func setUp() {
        super.setUp()
        useCase = DefaultSanitizeFolderTitleUseCase()
    }

    override func tearDown() {
        useCase = nil
        super.tearDown()
    }

    func test_1글자_제목_그대로_반환() {
        let input = String(repeating: "A", count: 1)
        let result = useCase.execute(title: input)

        XCTAssertEqual(result, input)
    }

    func test_99글자_제목_그대로_반환() {
        let input = String(repeating: "A", count: 99)
        let result = useCase.execute(title: input)

        XCTAssertEqual(result, input)
    }

    func test_100글자_제목_그대로_반환() {
        let input = String(repeating: "B", count: 100)
        let result = useCase.execute(title: input)

        XCTAssertEqual(result, input)
    }

    func test_101글자_제목_잘린_결과_반환() {
        let input = String(repeating: "C", count: 101)
        let expected = String(input.prefix(100))
        let result = useCase.execute(title: input)

        XCTAssertEqual(result.count, 100)
        XCTAssertEqual(result, expected)
    }

    func test_120글자_제목_잘린_결과_반환() {
        let input = String(repeating: "D", count: 120)
        let expected = String(input.prefix(100))
        let result = useCase.execute(title: input)

        XCTAssertEqual(result.count, 100)
        XCTAssertEqual(result, expected)
    }

    func test_빈_문자열은_그대로_반환() {
        let input = ""
        let result = useCase.execute(title: input)

        XCTAssertEqual(result, "")
    }
}
