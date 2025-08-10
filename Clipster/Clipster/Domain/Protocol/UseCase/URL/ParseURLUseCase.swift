import Foundation

protocol ParseURLUseCase {
    func execute(url: URL) async -> Result<(URLMetadata?, Bool), URLValidationError>
}
