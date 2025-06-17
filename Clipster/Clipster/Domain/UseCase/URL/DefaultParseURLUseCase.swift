import Foundation

final class DefaultParseURLUseCase: ParseURLUseCase {
    let urlMetaRepository: URLRepository

    init(urlMetaRepository: URLRepository) {
        self.urlMetaRepository = urlMetaRepository
    }

    func execute(urlString: String) async -> Result<(ParsedURLMetadata?, Bool), Error> {
        let correctedURLString = urlString.lowercased().hasPrefix("https://") ?
        urlString : "https://\(urlString)"

        guard let url = URL(string: correctedURLString) else {
            return .failure(URLError(.badURL))
        }
        return await urlMetaRepository.execute(url: url)
    }
}
