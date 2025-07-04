import XCTest
@testable import Clipster

final class SearchFoldersUseCaseTests: XCTestCase {
    private var useCase: SearchFoldersUseCase!
    private let folders = MockFolder.rootFolders

    override func setUp() {
        super.setUp()
        useCase = DefaultSearchFoldersUseCase()
    }

    override func tearDown() {
        useCase = nil
        super.tearDown()
    }

    func test_쿼리와_정확히_일치하는_폴더_검색() {
        let query = "Today Folder"

        let result = useCase.execute(query: query, in: folders)

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.title, query)
    }

    func test_쿼리를_포함하는_여러_폴더_검색() {
        let query = "Folder"

        let result = useCase.execute(query: query, in: folders)

        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.contains { $0.title == "Today Folder" })
        XCTAssertTrue(result.contains { $0.title == "Yesterday Folder" })
    }

    func test_쿼리에_앞뒤_공백이_있어도_검색() {
        let query = " Folder "

        let result = useCase.execute(query: query, in: folders)

        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.contains { $0.title == "Today Folder" })
        XCTAssertTrue(result.contains { $0.title == "Yesterday Folder" })
    }

    func test_대소문자가_달라도_검색() {
        let query = "folder"

        let result = useCase.execute(query: query, in: folders)

        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.contains { $0.title == "Today Folder" })
        XCTAssertTrue(result.contains { $0.title == "Yesterday Folder" })
    }

    func test_일치하는_결과가_없으면_빈_배열_반환() {
        let query = "결과 없는 쿼리"

        let result = useCase.execute(query: query, in: folders)

        XCTAssertTrue(result.isEmpty)
    }

    func test_빈_문자열로_검색하면_빈_배열_반환() {
        let query = ""

        let result = useCase.execute(query: query, in: folders)

        XCTAssertTrue(result.isEmpty)
    }

    func test_공백만_있는_쿼리는_빈_배열_반환() {
        let query = "   "

        let result = useCase.execute(query: query, in: folders)

        XCTAssertTrue(result.isEmpty)
    }
}
