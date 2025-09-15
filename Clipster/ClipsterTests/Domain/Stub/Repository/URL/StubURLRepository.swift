import Foundation
@testable import Clipster

final class StubURLRepository: URLRepository {
    let htmlResult: String
    let capturedScreenshot: Data?

    init(
        htmlResult: String,
        captureScreenshot: Data?
    ) {
        self.htmlResult = htmlResult
        self.capturedScreenshot = captureScreenshot
    }

    func fetchHTML(from url: URL) async -> Result<(String, Data?), URLValidationError> {
        return .success((htmlResult, capturedScreenshot))
    }
}
