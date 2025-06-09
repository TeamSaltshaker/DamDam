import Foundation

final class DefaultCheckValidityUseCase: CheckURLValidityUseCase {
    let urlValidationRepository: URLValidationRepository

    init(urlValidationRepository: URLValidationRepository) {
        self.urlValidationRepository = urlValidationRepository
    }

    func execute(urlString: String) async -> Result<Bool, Error> {
        guard let url = URL(string: urlString) else {
            return .failure(URLError(.badURL))
        }
        return await urlValidationRepository.execute(url: url)
    }
}
