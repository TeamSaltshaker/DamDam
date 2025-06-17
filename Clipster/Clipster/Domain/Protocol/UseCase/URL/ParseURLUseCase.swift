protocol ParseURLUseCase {
    func execute(urlString: String) async -> Result<(ParsedURLMetadata, Bool), Error>
}
