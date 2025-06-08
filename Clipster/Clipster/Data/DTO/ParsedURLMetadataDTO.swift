import Foundation

struct ParsedURLMetadataDTO {
    var url: URL
    var title: String
    var thumbnailImage: String
}

extension ParsedURLMetadataDTO {
    func toEntity() -> ParsedURLMetadata {
        ParsedURLMetadata(
            url: url,
            title: title,
            thumbnailImage: URL(string: thumbnailImage)
        )
    }
}
