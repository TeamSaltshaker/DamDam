import Foundation

final class DefaultParseURLMetadataUseCase: ParseURLMetadataUseCase {
    let urlMetadataRepository: URLMetadataRepository

    init(urlMetadataRepository: URLMetadataRepository) {
        self.urlMetadataRepository = urlMetadataRepository
    }

    func execute(urlString: String) async -> Result<ParsedURLMetadata, Error> {
        guard let url = URL(string: urlString) else {
            return .failure(URLError(.badURL))
        }
        return await urlMetadataRepository.execute(url: url)
    }
}
