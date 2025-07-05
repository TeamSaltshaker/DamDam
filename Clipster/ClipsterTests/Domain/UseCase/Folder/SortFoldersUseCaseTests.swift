import XCTest
@testable import Clipster

final class SortFoldersUseCaseTests: XCTestCase {
    private var useCase: SortFoldersUseCase!
    private var folders = MockFolder.rootFolders

    override func setUp() {
        super.setUp()
        useCase = DefaultSortFoldersUseCase()
    }

    override func tearDown() {
        useCase = nil
        super.tearDown()
    }

    func test_폴더명을_오름차순으로_정렬() {
        let option = FolderSortOption.title(.ascending)

        let result = useCase.execute(folders, by: option)

        XCTAssertEqual(result.map { $0.title }, ["Today Folder", "Yesterday Folder"])
    }

    func test_폴더명을_내림차순으로_정렬() {
        let option = FolderSortOption.title(.descending)

        let result = useCase.execute(folders, by: option)

        XCTAssertEqual(result.map { $0.title }, ["Yesterday Folder", "Today Folder"])
    }

    func test_생성일을_오름차순으로_정렬() {
        let option = FolderSortOption.createdAt(.ascending)

        let result = useCase.execute(folders, by: option)

        XCTAssertEqual(result.map { $0.title }, ["Yesterday Folder", "Today Folder"])
    }

    func test_생성일을_내림차순으로_정렬() {
        let option = FolderSortOption.createdAt(.descending)

        let result = useCase.execute(folders, by: option)

        XCTAssertEqual(result.map { $0.title }, ["Today Folder", "Yesterday Folder"])
    }

    func test_수정일을_오름차순으로_정렬() {
        let option = FolderSortOption.updatedAt(.ascending)

        let result = useCase.execute(folders, by: option)

        XCTAssertEqual(result.map { $0.title }, ["Yesterday Folder", "Today Folder"])
    }

    func test_수정일을_내림차순으로_정렬() {
        let option = FolderSortOption.updatedAt(.descending)

        let result = useCase.execute(folders, by: option)

        XCTAssertEqual(result.map { $0.title }, ["Today Folder", "Yesterday Folder"])
    }

    func test_빈_배열을_정렬하면_빈_배열을_반환() {
        let emptyFolders: [Folder] = []
        let option = FolderSortOption.updatedAt(.descending)

        let result = useCase.execute(emptyFolders, by: option)

        XCTAssertTrue(result.isEmpty)
    }
}
