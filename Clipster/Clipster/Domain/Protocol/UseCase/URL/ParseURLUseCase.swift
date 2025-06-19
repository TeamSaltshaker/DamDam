import Foundation

protocol ParseURLUseCase {
    func execute(urlString: String) async -> Result<(ParsedURLMetadata?, Bool), URLValidationError>
}
