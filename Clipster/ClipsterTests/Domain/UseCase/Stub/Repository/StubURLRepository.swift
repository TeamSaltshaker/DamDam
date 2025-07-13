import Foundation
@testable import Clipster

final class StubURLRepository: URLRepository {
    let resolveRedirectURL: URL
    let htmlResult: String
    let captureScreenshot: Data?

    init(
        resolveRedirectURL: URL,
        htmlResult: String,
        captureScreenshot: Data?
    ) {
        self.resolveRedirectURL = resolveRedirectURL
        self.htmlResult = htmlResult
        self.captureScreenshot = captureScreenshot
    }

    func fetchHTML(from url: URL) async -> Result<String, URLValidationError> {
        return .success(htmlResult)
    }
    
    func resolveRedirectURL(initialURL: URL) async -> URL {
        return resolveRedirectURL
    }
    
    func captureScreenshot(rect: CGRect?) async -> Data? {
        return captureScreenshot
    }
}
