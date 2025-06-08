import Foundation

final class DefaultCheckVaildityUseCase: CheckURLValidityUseCase {
    let repository: URLValidationRepository

    init(repository: URLValidationRepository) {
        self.repository = repository
    }

    func execute(urlString: String) async throws -> Bool {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        return try await repository.execute(url: url).get()
    }
}
