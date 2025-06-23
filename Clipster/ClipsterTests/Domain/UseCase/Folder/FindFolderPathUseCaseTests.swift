import XCTest
@testable import Clipster

final class FindFolderPathUseCaseTests: XCTestCase {
    private var useCase: FindFolderPathUseCase!

    override func setUp() {
        super.setUp()
        useCase = DefaultFindFolderPathUseCase()
    }

    override func tearDown() {
        useCase = nil
        super.tearDown()
    }

    private func makeFolder(
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

    func test_타겟_폴더가_폴더_트리에_존재하면_정확한_경로_반환() {
        let subSub = makeFolder(id: "00000000-0000-0000-0000-000000000003", parentID: "00000000-0000-0000-0000-000000000002", title: "SubSub", depth: 2)
        let sub = makeFolder(id: "00000000-0000-0000-0000-000000000002", parentID: "00000000-0000-0000-0000-000000000001", title: "Sub", depth: 1, folders: [subSub])
        let top = makeFolder(id: "00000000-0000-0000-0000-000000000001", title: "Top", depth: 0, folders: [sub])

        let folders = [top]

        let testCases: [(Folder, [UUID])] = [
            (top, [top.id]),
            (sub, [top.id, sub.id]),
            (subSub, [top.id, sub.id, subSub.id])
        ]

        for (target, expectedPath) in testCases {
            let result = useCase.execute(to: target, in: folders)
            XCTAssertNotNil(result)
            XCTAssertEqual(result!.map { $0.id }, expectedPath)
        }
    }

    func test_타겟_폴더가_존재하지_않으면_nil_반환() {
        let unknown = makeFolder(id: "00000000-0000-0000-0000-000000000009", title: "Unknown", depth: 0)
        let top = makeFolder(id: "00000000-0000-0000-0000-000000000001", title: "Top", depth: 0)

        let result = useCase.execute(to: unknown, in: [top])
        XCTAssertNil(result)
    }

    func test_빈_폴더_목록이면_nil_반환() {
        let target = makeFolder(id: "00000000-0000-0000-0000-000000000001", title: "Target", depth: 0)
        let result = useCase.execute(to: target, in: [])

        XCTAssertNil(result)
    }
}
