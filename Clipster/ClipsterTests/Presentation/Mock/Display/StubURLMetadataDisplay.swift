import Foundation
@testable import Clipster

enum StubURLMetadataDisplay {
    static let urlMetaDataDisplay = URLMetadataDisplay(
        url: URL(string: "https://example.com")!,
        title: "Sample Title",
        description: "example",
        thumbnailImageURL: URL(string: "https://example.com/thumb.png"),
        screenshotImageData: nil,
    )

    static let urlMetadataDisplayWithoutThumbnailAndScreenshot = URLMetadataDisplay(
        url: URL(string: "https://example.com")!,
        title: "Sample Title",
        description: "example",
        thumbnailImageURL: nil,
        screenshotImageData: nil,
    )
    
    static let urlMetadataDisplayWithScreenshot = URLMetadataDisplay(
        url: URL(string: "https://example.com")!,
        title: "Sample Title",
        description: "example",
        thumbnailImageURL: nil,
        screenshotImageData: Data(),
    )

    static let urlMetadataDisplayWithThumbnail = URLMetadataDisplay(
        url: URL(string: "https://example.com")!,
        title: "Sample Title",
        description: "example",
        thumbnailImageURL: URL(string: "https://example.com/thumb.png"),
        screenshotImageData: nil,
    )
}
