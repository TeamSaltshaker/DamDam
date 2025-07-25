import XCTest
import RxSwift
@testable import Clipster

final class ShareReactorTests: XCTestCase {
    private var parseURLUseCase: MockParseURLUseCase!
    private var createClipUseCase: MockCreateClipUseCase!
    private var extractExtensionContextUseCase: MockExtractExtensionContextUseCase!
    private var disposeBag: DisposeBag!
    private var reactor: ShareReactor!

    override func setUp() {
        super.setUp()
        parseURLUseCase = MockParseURLUseCase()
        createClipUseCase = MockCreateClipUseCase()
        extractExtensionContextUseCase = MockExtractExtensionContextUseCase()
        disposeBag = DisposeBag()
        reactor = ShareReactor(
            parseURLUseCase: parseURLUseCase,
            createClipUseCase: createClipUseCase,
            extractExtensionContextUseCase: extractExtensionContextUseCase
        )
    }

    override func tearDown() {
        super.tearDown()
        parseURLUseCase = nil
        createClipUseCase = nil
        extractExtensionContextUseCase = nil
        disposeBag = nil
        reactor = nil
    }
}
