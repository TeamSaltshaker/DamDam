enum LoginError: Error {
    case invalidToken
    case invalidRootVC
    case invalidClientID
    case unsupportedType
    case cancelled
}
