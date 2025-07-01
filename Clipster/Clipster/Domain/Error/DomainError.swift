enum DomainError: Error {
    case unknownError
    case entityNotFound
    case fetchFailed
    case insertFailed
    case updateFailed
    case deleteFailed
}
