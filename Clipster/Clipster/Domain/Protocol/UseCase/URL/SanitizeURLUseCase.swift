import Foundation

protocol SanitizeURLUseCase {
    func execute(urlString: String) -> Result<URL, URLValidationError>
}
