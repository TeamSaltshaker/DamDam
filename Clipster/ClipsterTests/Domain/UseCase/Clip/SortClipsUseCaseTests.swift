import XCTest
@testable import Clipster

final class SortClipsUseCaseTests: XCTestCase {
    private var useCase: SortClipsUseCase!
    private let clips = MockClip.unsortedClips

    override func setUp() {
        super.setUp()
        useCase = DefaultSortClipsUseCase()
    }

    override func tearDown() {
        useCase = nil
        super.tearDown()
    }

    func test_타이틀을_오름차순으로_정렬() {
        let option = ClipSortOption.title(.ascending)

        let result = useCase.execute(clips, by: option)

        XCTAssertEqual(result.map { $0.title }, ["Apple", "Banana", "Cherry"])
    }

    func test_타이틀을_내림차순으로_정렬() {
        let option = ClipSortOption.title(.descending)

        let result = useCase.execute(clips, by: option)

        XCTAssertEqual(result.map { $0.title }, ["Cherry", "Banana", "Apple"])
    }

    func test_최근_방문일을_오름차순으로_정렬() {
        let option = ClipSortOption.lastVisitedAt(.ascending)

        let result = useCase.execute(clips, by: option)

        XCTAssertEqual(result.map { $0.title }, ["Banana", "Cherry", "Apple"])
    }

    func test_최근_방문일을_내림차순으로_정렬() {
        let option = ClipSortOption.lastVisitedAt(.descending)

        let result = useCase.execute(clips, by: option)

        XCTAssertEqual(result.map { $0.title }, ["Apple", "Cherry", "Banana"])
    }

    func test_생성일을_오름차순으로_정렬() {
        let option = ClipSortOption.createdAt(.ascending)

        let result = useCase.execute(clips, by: option)

        XCTAssertEqual(result.map { $0.title }, ["Apple", "Banana", "Cherry"])
    }

    func test_생성일을_내림차순으로_정렬() {
        let option = ClipSortOption.createdAt(.descending)

        let result = useCase.execute(clips, by: option)

        XCTAssertEqual(result.map { $0.title }, ["Cherry", "Banana", "Apple"])
    }

    func test_수정일을_오름차순으로_정렬() {
        let option = ClipSortOption.updatedAt(.ascending)

        let result = useCase.execute(clips, by: option)

        XCTAssertEqual(result.map { $0.title }, ["Apple", "Cherry", "Banana"])
    }

    func test_수정일을_내림차순으로_정렬() {
        let option = ClipSortOption.updatedAt(.descending)

        let result = useCase.execute(clips, by: option)

        XCTAssertEqual(result.map { $0.title }, ["Banana", "Cherry", "Apple"])
    }

    func test_빈_배열을_정렬하면_빈_배열을_반환() {
        let emptyClips: [Clip] = []
        let option = ClipSortOption.updatedAt(.descending)

        let result = useCase.execute(emptyClips, by: option)

        XCTAssertTrue(result.isEmpty)
    }
}
