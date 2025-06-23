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

    func test_100글자_이하_제목_그대로_반환() {
        let input = String(repeating: "A", count: 100)
        let result = useCase.execute(title: input)

        XCTAssertEqual(result, input)
    }

    func test_100글자_초과_제목_잘린_결과_반환() {
        let input = String(repeating: "B", count: 120)
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
