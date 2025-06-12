import Foundation

final class DefaultCheckValidityUseCase: CheckURLValidityUseCase {
    let urlValidationRepository: URLValidationRepository

    init(urlValidationRepository: URLValidationRepository) {
        self.urlValidationRepository = urlValidationRepository
    }

    func execute(urlString: String) async -> Result<Bool, Error> {
        let correctedURLString: String
        if urlString.lowercased().hasPrefix("https://") {
            correctedURLString = urlString
        } else {
            correctedURLString = "https://\(urlString)"
        }
        guard let url = URL(string: correctedURLString) else {
            return .failure(URLError(.badURL))
        }
        return await urlValidationRepository.execute(url: url)
    }
}
