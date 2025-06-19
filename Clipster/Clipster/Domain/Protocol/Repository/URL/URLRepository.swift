import Foundation

protocol URLRepository {
    func execute(url: URL) async -> Result<(ParsedURLMetadata?, Bool), URLValidationError>
}
