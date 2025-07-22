import Foundation
@testable import Clipster

enum MockURLMetadataDisplay {
    static let urlMetaDataDisplay = URLMetadataDisplay(
        url: URL(string: "https://example.com")!,
        title: "Sample Title",
        description: "example",
        thumbnailImageURL: URL(string: "https://example.com/thumb.png"),
        screenshotImageData: nil,
    )
}
