@testable import Clipster
import Foundation

final class MockParseURLUseCase: ParseURLUseCase {
    private(set) var didCallExecute: Bool = false
    private(set) var receivedURL: URL?

    var executeResult: Result<(URLMetadata?, Bool), URLValidationError>!

    func execute(url: URL) async -> Result<(URLMetadata?, Bool), URLValidationError> {
        didCallExecute = true
        receivedURL = url

        return executeResult
    }
}
