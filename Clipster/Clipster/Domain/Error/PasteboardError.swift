enum PasteboardError: Error {
    case notDetectedURL
    case failedToRead
    case failedInitNSDataDetector
    case failedExtractURL
}
