import Foundation

final class DefaultParseURLMetadataUseCase: ParseURLMetadataUseCase {
    let urlMetadataRepository: URLMetadataRepository

    init(urlMetadataRepository: URLMetadataRepository) {
        self.urlMetadataRepository = urlMetadataRepository
    }

    func execute(urlString: String) async -> Result<ParsedURLMetadata, Error> {
        let correctedURLString: String
        if urlString.lowercased().hasPrefix("https://") {
            correctedURLString = urlString
        } else {
            correctedURLString = "https://\(urlString)"
        }
        guard let url = URL(string: correctedURLString) else {
            return .failure(URLError(.badURL))
        }
        return await urlMetadataRepository.execute(url: url)
    }
}
