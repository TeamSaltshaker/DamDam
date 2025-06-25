import Foundation

protocol ParseURLUseCase {
    func execute(urlString: String) async -> Result<(URLMetadata?, Bool), URLValidationError>
}
