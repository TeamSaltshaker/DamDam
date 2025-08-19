@testable import Clipster
import Foundation

final class MockParseURLUseCase: ParseURLUseCase {
    private(set) var didCallExecute: Bool = false
    private(set) var receivedURL: URL?

    var executeResult: Result<(URLMetadata, ParseResultType), URLValidationError>!

    func execute(url: URL) async -> Result<(URLMetadata, ParseResultType), URLValidationError> {
        didCallExecute = true
        receivedURL = url

        return executeResult
    }
}
