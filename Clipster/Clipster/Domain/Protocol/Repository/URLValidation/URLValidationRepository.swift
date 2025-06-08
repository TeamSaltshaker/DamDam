import Foundation

protocol URLValidationRepository {
    func execute(url: URL) async -> Result<Bool, Error>
}
