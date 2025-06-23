import XCTest
@testable import Clipster

final class CanSaveFolderUseCaseTests: XCTestCase {
    private var useCase: CanSaveFolderUseCase!

    override func setUp() {
        super.setUp()
        useCase = DefaultCanSaveFolderUseCase()
    }

    override func tearDown() {
        useCase = nil
        super.tearDown()
    }

    func test_빈_문자열이면_false_반환() {
        let result = useCase.execute(title: "")
        XCTAssertFalse(result)
    }

    func test_공백_문자열이면_false_반환() {
        let result = useCase.execute(title: "     ")
        XCTAssertFalse(result)
    }

    func test_줄바꿈_탭_등_공백문자만_포함되면_false_반환() {
        let result = useCase.execute(title: "\n\t  ")
        XCTAssertFalse(result)
    }

    func test_정상_문자열이면_true_반환() {
        let result = useCase.execute(title: "iOS")
        XCTAssertTrue(result)
    }
}
