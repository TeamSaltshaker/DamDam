import Foundation
@testable import Clipster

enum MockURLMetadata {
    static let urlMetadata = URLMetadata(
        url: URL(string: "https://example.com")!,
        title: "Sample Title",
        description: "example",
        thumbnailImageURL: URL(string: "https://example.com/thumb.png"),
        screenshotData: nil,
    )
}
