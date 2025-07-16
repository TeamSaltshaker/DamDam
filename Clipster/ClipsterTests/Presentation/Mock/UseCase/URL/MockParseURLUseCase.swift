@testable import Clipster

final class MockParseURLUseCase: ParseURLUseCase {
    private(set) var didCallExecute: Bool = false
    var shouldSucceed: Bool = false
    private(set) var receivedURLString: String?

    func execute(urlString: String) async -> Result<(URLMetadata?, Bool), URLValidationError> {
        didCallExecute = true
        receivedURLString = urlString
        return shouldSucceed ? .success((MockURLMetadata.urlMetaData, true)) : .failure(.unknown)
    }
}
