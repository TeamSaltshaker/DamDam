import Foundation
@testable import Clipster

final class StubURLRepository: URLRepository {
    let resolvedRedirectURL: URL
    let htmlResult: String
    let capturedScreenshot: Data?

    init(
        resolveRedirectURL: URL,
        htmlResult: String,
        captureScreenshot: Data?
    ) {
        self.resolvedRedirectURL = resolveRedirectURL
        self.htmlResult = htmlResult
        self.capturedScreenshot = captureScreenshot
    }

    func fetchHTML(from url: URL) async -> Result<String, URLValidationError> {
        return .success(htmlResult)
    }
    
    func resolveRedirectURL(initialURL: URL) async -> URL {
        return resolvedRedirectURL
    }
    
    func captureScreenshot(rect: CGRect?) async -> Data? {
        return capturedScreenshot
    }
}
