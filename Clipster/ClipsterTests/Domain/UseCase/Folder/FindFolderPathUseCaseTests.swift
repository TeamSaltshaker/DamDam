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

    func test_타겟_폴더가_폴더_트리에_존재하면_정확한_경로_반환() {
        let folder = MockFolder.someFolder
        let tree = [folder]
        let child = folder.folders.first!

        let testCases: [(target: Folder, expectedPath: [Folder])] = [
            (folder, [folder]),
            (child, [folder, child])
        ]

        for (target, expectedPath) in testCases {
            let result = useCase.execute(to: target, in: tree)

            XCTAssertNotNil(result)
            XCTAssertEqual(result?.map(\.id), expectedPath.map(\.id))
        }
    }

    func test_타겟_폴더가_존재하지_않으면_nil_반환() {
        let tree = [MockFolder.someFolder]
        let nonExistentFolder = MockFolder.folderToEdit

        let result = useCase.execute(to: nonExistentFolder, in: tree)

        XCTAssertNil(result)
    }

    func test_빈_폴더_목록이면_nil_반환() {
        let targetFolder = MockFolder.someFolder

        let result = useCase.execute(to: targetFolder, in: [])

        XCTAssertNil(result)
    }
}
