import Foundation

protocol URLRepository {
    func fetchHTML(from url: URL) async -> Result<(String, Data?), URLValidationError>
}
