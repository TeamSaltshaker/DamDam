import Foundation

struct URLMetadataDisplay: Hashable {
    let url: URL
    let title: String
    let description: String
    let thumbnailImageURL: URL?
    let screenshotImageData: Data?
}
