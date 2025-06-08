import Foundation

final class DefaultCheckVaildityUseCase: CheckURLValidityUseCase {
    let repository: URLValidationRepository

    init(repository: URLValidationRepository) {
        self.repository = repository
    }

    func execute(urlString: String) async -> Result<Bool, Error> {
        guard let url = URL(string: urlString) else {
            return .failure(URLError(.badURL))
        }
        return await repository.execute(url: url)
    }
}
