import Foundation

protocol URLRepository {
    func fetchHTML(from url: URL) async -> Result<String, URLValidationError>
    func resolveRedirectURL(initialURL: URL) async -> URL
    func captureScreenshot(rect: CGRect?) async -> Data?
}
