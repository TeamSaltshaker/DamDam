import Foundation

final class DefaultParseURLUseCase: ParseURLUseCase {
    let urlRepository: URLRepository

    init(urlMetaRepository: URLRepository) {
        self.urlRepository = urlMetaRepository
    }

    func execute(urlString: String) async -> Result<(ParsedURLMetadata?, Bool), Error> {
        let correctedURLString = urlString.lowercased().hasPrefix("https://") ?
        urlString : "https://\(urlString)"

        guard let url = URL(string: correctedURLString) else {
            return .failure(URLError(.badURL))
        }
        return await urlRepository.execute(url: url)
    }
}
