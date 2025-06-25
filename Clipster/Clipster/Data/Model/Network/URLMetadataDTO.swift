import Foundation

struct URLMetadataDTO {
    var url: URL
    var title: String
    let thumbnailImageURL: URL?
    let screenshotData: Data?
}

extension URLMetadataDTO {
    func toEntity() -> URLMetadata {
        URLMetadata(
            url: url,
            title: title,
            thumbnailImageURL: thumbnailImageURL,
            screenshotData: screenshotData
        )
    }
}
