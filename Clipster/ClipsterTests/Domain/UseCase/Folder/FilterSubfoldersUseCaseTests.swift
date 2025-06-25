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
        let top1 = makeFolder(id: "00000001-0000-0000-0000-000000000000", title: "Top 1", depth: 0)
        let top2 = makeFolder(id: "00000002-0000-0000-0000-000000000000", title: "Top 2", depth: 0)
        let top3 = makeFolder(id: "00000003-0000-0000-0000-000000000000", title: "Top 3", depth: 0)
        let topLevel = [top1, top2, top3]

        let result = useCase.execute(topLevelFolders: topLevel, currentPath: [], folder: top2)

        XCTAssertEqual(result.count, 2)
        XCTAssertFalse(result.contains(where: { $0.id == top2.id }))
    }

    func test_하위폴더_목록에서_자기자신을_제외하고_반환() {
        let sub1 = makeFolder(id: "00000000-0001-0000-0000-000000000000", parentID: "00000001-0000-0000-0000-000000000000", title: "Sub 1", depth: 1)
        let sub2 = makeFolder(id: "00000000-0002-0000-0000-000000000000", parentID: "00000001-0000-0000-0000-000000000000", title: "Sub 2", depth: 1)
        let parent = makeFolder(id: "00000001-0000-0000-0000-000000000000", title: "Parent", depth: 0, folders: [sub1, sub2])
        let topLevel = [parent]

        let currentPath = [parent]

        let result = useCase.execute(topLevelFolders: topLevel, currentPath: currentPath, folder: sub2)

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, sub1.id)
    }

    func test_최상위폴더_목록에서_제외할_폴더가_nil이면_전체_폴더_목록_반환() {
        let top1 = makeFolder(id: "00000001-0000-0000-0000-000000000000", title: "Top 1", depth: 0)
        let top2 = makeFolder(id: "00000002-0000-0000-0000-000000000000", title: "Top 2", depth: 0)
        let top3 = makeFolder(id: "00000003-0000-0000-0000-000000000000", title: "Top 3", depth: 0)
        let topLevel = [top1, top2, top3]

        let result = useCase.execute(topLevelFolders: topLevel, currentPath: [], folder: nil)

        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(Set(result.map(\.id)), Set([top1.id, top2.id, top3.id]))
    }

    func test_하위폴더_목록에서_제외할_폴더가_nil이면_전체_폴더_목록_반환() {
        let sub1 = makeFolder(id: "00000000-0001-0000-0000-000000000000", parentID: "00000001-0000-0000-0000-000000000000", title: "Sub 1", depth: 1)
        let sub2 = makeFolder(id: "00000000-0002-0000-0000-000000000000", parentID: "00000001-0000-0000-0000-000000000000", title: "Sub 2", depth: 1)
        let parent = makeFolder(id: "00000001-0000-0000-0000-000000000000", title: "Parent", depth: 0, folders: [sub1, sub2])
        let topLevel = [parent]
        let currentPath = [parent]

        let result = useCase.execute(topLevelFolders: topLevel, currentPath: currentPath, folder: nil)

        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.contains(where: { $0.id == sub1.id }))
        XCTAssertTrue(result.contains(where: { $0.id == sub2.id }))
    }

    func test_현재폴더경로가_비어있고_제외할_폴더가_nil이면_최상위폴더_목록을_그대로_반환() {
        let top1 = makeFolder(id: "00000001-0000-0000-0000-000000000000", title: "Top 1", depth: 0)
        let top2 = makeFolder(id: "00000002-0000-0000-0000-000000000000", title: "Top 2", depth: 0)
        let topLevel = [top1, top2]

        let result = useCase.execute(topLevelFolders: topLevel, currentPath: [], folder: nil)

        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(Set(result.map(\.id)), Set(topLevel.map(\.id)))
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
