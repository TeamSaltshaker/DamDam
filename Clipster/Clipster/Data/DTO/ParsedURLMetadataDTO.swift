import Foundation

struct ParsedURLMetadataDTO {
    var url: URL
    var title: String
    let thumbnailImageURL: URL?
    let screenshotData: Data?
}

extension ParsedURLMetadataDTO {
    func toEntity() -> ParsedURLMetadata {
        ParsedURLMetadata(
            url: url,
            title: title,
            thumbnailImageURL: thumbnailImageURL,
            screenshotData: screenshotData
        )
    }
}
