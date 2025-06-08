import Foundation

struct ParsedURLMetadataDTO {
    var url: URL
    var title: String
    var thumbnailImageURL: String
}

extension ParsedURLMetadataDTO {
    func toEntity() -> ParsedURLMetadata {
        ParsedURLMetadata(
            url: url,
            title: title,
            thumbnailImageURL: URL(string: thumbnailImageURL)
        )
    }
}
