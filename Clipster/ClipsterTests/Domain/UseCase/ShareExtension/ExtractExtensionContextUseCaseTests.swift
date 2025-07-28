import XCTest
@testable import Clipster

final class ExtractExtensionContextUseCaseTests: XCTestCase {
    private var useCase: ExtractExtensionContextUseCase!

    override func setUp() {
        super.setUp()
        useCase = DefaultExtractExtensionContextUseCase()
    }

    override func tearDown() {
        super.tearDown()
        useCase = nil
    }
}
