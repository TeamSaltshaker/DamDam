import Foundation

protocol URLRepository {
    func execute(url: URL) async -> Result<(URLMetadata?, Bool), URLValidationError>
}
