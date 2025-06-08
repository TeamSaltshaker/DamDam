import Foundation

final class DefaultParseURLMetadataUseCase: ParseURLMetadataUseCase {
    let repository: URLMetadataRepository

    init(repository: URLMetadataRepository) {
        self.repository = repository
    }

    func execute(urlString: String) async -> Result<ParsedURLMetadata, Error> {
        guard let url = URL(string: urlString) else {
            return .failure(URLError(.badURL))
        }
        return await repository.execute(url: url)
    }
}
