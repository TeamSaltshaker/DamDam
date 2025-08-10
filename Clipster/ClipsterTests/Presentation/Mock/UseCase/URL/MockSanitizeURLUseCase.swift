@testable import Clipster
import Foundation

final class MockSanitizeURLUseCase: SanitizeURLUseCase {
    private(set) var didCallExecute: Bool = false
    private(set) var receivedURLString: String?

    var executeResult: Result<URL, URLValidationError>!

    func execute(urlString: String) -> Result<URL, URLValidationError> {
        didCallExecute = true
        receivedURLString = urlString

        return executeResult
    }
}
