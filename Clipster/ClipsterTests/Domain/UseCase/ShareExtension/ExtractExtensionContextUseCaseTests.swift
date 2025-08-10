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

    func test_execute_URL_형태의_텍스트_공유_시_URL_추출_성공() async {
        let expectedURLString = "http://google.com"
        let mockProvider = NSItemProvider(
            item: expectedURLString as NSString,
            typeIdentifier: UTType.plainText.identifier
        )

        let extensionItem = NSExtensionItem()
        extensionItem.attachments = [mockProvider]

        let result = await useCase.execute(
            extensionItems: [extensionItem]
        )

        switch result {
        case .success(let url):
            XCTAssertEqual(url.absoluteString, expectedURLString)
        case .failure:
            XCTFail("URL 추출에 실패했습니다.")
        }
    }

    func test_execute_URL_형태의_Data_공유_시_URL_추출_성공() async {
        let receivedData = "현재 페이지의 URL은 http://google.com 입니다."
        let expectedURL = URL(string: "http://google.com")

        guard let urlData = receivedData.data(using: .utf8) else {
            XCTFail("테스트 데이터 생성에 실패했습니다.")
            return
        }

        let mockProvider = NSItemProvider(
            item: urlData as NSData,
            typeIdentifier: UTType.data.identifier
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
