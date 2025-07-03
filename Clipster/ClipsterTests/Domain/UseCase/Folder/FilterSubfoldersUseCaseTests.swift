import XCTest
@testable import Clipster

final class FilterSubfoldersUseCaseTests: XCTestCase {
    private var useCase: FilterSubfoldersUseCase!

    override func setUp() {
        super.setUp()
        useCase = DefaultFilterSubfoldersUseCase()
    }

    override func tearDown() {
        useCase = nil
        super.tearDown()
    }

    func test_최상위폴더_목록에서_자기자신을_제외하고_반환() {
        let tree = MockFolder.rootFolders + [MockFolder.someFolder]
        let folder = MockFolder.someFolder

        let result = useCase.execute(folder, from: tree)

        XCTAssertEqual(result.count, tree.count - 1)
        XCTAssertFalse(result.contains(where: { $0.id == folder.id }))
    }

    func test_하위폴더_목록에서_자기자신을_제외하고_반환() {
        let tree = [MockFolder.someFolder]
        let folder = MockFolder.someFolder.folders.first!

        let result = useCase.execute(folder, from: tree)

        let resultRoot = result.first
        let uikitExists = resultRoot?.folders.contains(where: { $0.id == folder.id }) ?? true

        XCTAssertEqual(result.count, 1)
        XCTAssertFalse(uikitExists)
        XCTAssertEqual(resultRoot?.folders.count, 1)
    }

    func test_제외할_폴더가_없으면_전체_폴더_목록_반환() {
        let folderTree = [MockFolder.someFolder]
        let nonExistentFolder = MockFolder.folderToEdit

        let result = useCase.execute(nonExistentFolder, from: folderTree)

        XCTAssertEqual(result.count, folderTree.count)
        XCTAssertEqual(result.first?.id, folderTree.first?.id)
        XCTAssertEqual(result.first?.folders.count, folderTree.first?.folders.count)
    }
}

private extension FilterSubfoldersUseCaseTests {
    func makeFolder(
        id: String,
        parentID: String? = nil,
        title: String,
        depth: Int,
        folders: [Folder] = [],
        clips: [Clip] = []
    ) -> Folder {
        let now = Date()
        return Folder(
            id: UUID(uuidString: id)!,
            parentFolderID: parentID.flatMap(UUID.init(uuidString:)),
            title: title,
            depth: depth,
            folders: folders,
            clips: clips,
            createdAt: now,
            updatedAt: now,
            deletedAt: nil
        )
    }
}
