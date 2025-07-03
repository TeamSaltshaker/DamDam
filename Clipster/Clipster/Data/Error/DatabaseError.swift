enum DatabaseError: Error {
    case fetchFailed
    case insertFailed
    case updateFailed
    case deleteFailed
}
