import Foundation

final class DefaultParseURLUseCase: ParseURLUseCase {
    let urlRepository: URLRepository

    init(urlMetaRepository: URLRepository) {
        self.urlRepository = urlMetaRepository
    }

    func execute(urlString: String) async -> Result<(ParsedURLMetadata?, Bool), URLValidationError> {
        let lowercased = urlString.lowercased()
        let correctedURLString: String

        if lowercased.hasPrefix("https://") || lowercased.hasPrefix("http://") {
            correctedURLString = urlString
        } else {
            correctedURLString = "https://\(urlString)"
        }

        guard correctedURLString != "https://" || correctedURLString != "http://" else {
            return .failure(.badURL)
        }

        guard let url = URL(string: correctedURLString) else {
            return .failure(.badURL)
        }

        guard let host = url.host, host.contains(".") else {
            return .failure(.badURL)
        }

        return await urlRepository.execute(url: url)
    }
}
