@testable import Clipster

final class MockParseURLUseCase: ParseURLUseCase {
    private(set) var didCallExecute: Bool = false
    private(set) var receivedURLString: String?

    var executeResult: Result<(URLMetadata?, Bool), URLValidationError>!

    func execute(urlString: String) async -> Result<(URLMetadata?, Bool), URLValidationError> {
        didCallExecute = true
        receivedURLString = urlString

        return executeResult
    }
}
