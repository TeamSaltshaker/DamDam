enum URLValidationError: Error {
    case badURL
    case timeOut
    case unsupportedURL
    case emptyHTMLContent
    case notFoundedWKURL
    case unknown
}
