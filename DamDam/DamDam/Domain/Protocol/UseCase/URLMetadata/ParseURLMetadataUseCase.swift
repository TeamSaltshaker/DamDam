protocol ParseURLMetadataUseCase {
    func execute(urlString: String) async -> Result<ParsedURLMetadata, Error>
}
