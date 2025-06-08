import Foundation

protocol URLMetadataRepository {
    func execute(url: URL) async -> Result<ParsedURLMetadata, Error>
}
