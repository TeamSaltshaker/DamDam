import XCTest
import UniformTypeIdentifiers
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

    func test_execute_URL_공유_시_URL_추출_성공() async {
        let expectedURL = URL(string: "http://google.com")!
        let mockProvider = NSItemProvider(
            item: expectedURL as NSURL,
            typeIdentifier: UTType.url.identifier
        )

        let extensionItem = NSExtensionItem()
        extensionItem.attachments = [mockProvider]

        let result = await useCase.execute(
            extensionItems: [extensionItem]
        )

        switch result {
        case .success(let url):
            XCTAssertEqual(url, expectedURL)
        case .failure:
            XCTFail("URL 추출에 실패했습니다.")
        }
    }
}
