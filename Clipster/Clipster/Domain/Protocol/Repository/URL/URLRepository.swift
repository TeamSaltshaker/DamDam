import Foundation

protocol URLRepository {
    func fetchHTML(from url: URL) async -> Result<(String, Data?), URLValidationError>
    func resolveRedirectURL(initialURL: URL) async -> URL
    func captureScreenshot(rect: CGRect?) async -> Data?
}
