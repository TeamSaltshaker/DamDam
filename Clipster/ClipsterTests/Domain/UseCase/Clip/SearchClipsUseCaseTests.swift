import XCTest
@testable import Clipster

final class SearchClipsUseCaseTests: XCTestCase {
    private var useCase: SearchClipsUseCase!
    private let clips = MockClip.unvisitedClips

    override func setUp() {
        super.setUp()
        useCase = DefaultSearchClipsUseCase()
    }

    override func tearDown() {
        useCase = nil
        super.tearDown()
    }

    func test_쿼리가_제목과_정확히_일치하는_클립_검색() {
        let query = "Example Title 1"

        let result = useCase.execute(query: query, in: clips)

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.title, query)
    }

    func test_쿼리가_URL과_정확히_일치하는_클립_검색() {
        let query = "https://example.com/1"

        let result = useCase.execute(query: query, in: clips)

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.url.absoluteString, query)
    }

    func test_쿼리가_메모와_정확히_일치하는_클립_검색() {
        let query = "Clip 1"

        let result = useCase.execute(query: query, in: clips)

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.memo, query)
    }

    func test_제목에_쿼리를_포함하는_여러_클립_검색() {
        let query = "Example"

        let result = useCase.execute(query: query, in: clips)

        XCTAssertEqual(result.count, 3)
        XCTAssertTrue(result.contains { $0.title == "Example Title 1" })
        XCTAssertTrue(result.contains { $0.title == "Example Title 2" })
        XCTAssertTrue(result.contains { $0.title == "Example Title 3" })
    }

    func test_URL에_쿼리를_포함하는_여러_클립_검색() {
        let query = "com"

        let result = useCase.execute(query: query, in: clips)

        XCTAssertEqual(result.count, 3)
        XCTAssertTrue(result.contains { $0.url.absoluteString == "https://example.com/1" })
        XCTAssertTrue(result.contains { $0.url.absoluteString == "https://example.com/2" })
        XCTAssertTrue(result.contains { $0.url.absoluteString == "https://example.com/3" })
    }

    func test_메모에_쿼리를_포함하는_여러_클립_검색() {
        let query = "Clip"

        let result = useCase.execute(query: query, in: clips)

        XCTAssertEqual(result.count, 3)
        XCTAssertTrue(result.contains { $0.memo == "Clip 1" })
        XCTAssertTrue(result.contains { $0.memo == "Clip 2" })
        XCTAssertTrue(result.contains { $0.memo == "Clip 3" })
    }

    func test_쿼리에_앞뒤_공백이_있어도_검색() {
        let query = " Example Title 1 "

        let result = useCase.execute(query: query, in: clips)

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.title, "Example Title 1")
    }

    func test_대소문자가_달라도_검색() {
        let query = "example title 1"

        let result = useCase.execute(query: query, in: clips)

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.title, "Example Title 1")
    }

    func test_일치하는_결과가_없으면_빈_배열_반환() {
        let query = "결과 없는 쿼리"

        let result = useCase.execute(query: query, in: clips)

        XCTAssertTrue(result.isEmpty)
    }

    func test_빈_문자열로_검색하면_빈_배열_반환() {
        let query = ""

        let result = useCase.execute(query: query, in: clips)

        XCTAssertTrue(result.isEmpty)
    }

    func test_공백만_있는_쿼리는_빈_배열_반환() {
        let query = "   "

        let result = useCase.execute(query: query, in: clips)

        XCTAssertTrue(result.isEmpty)
    }
}
