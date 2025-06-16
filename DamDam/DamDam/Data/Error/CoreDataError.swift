enum CoreDataError: Error {
    case entityNotFound
    case mapFailed
    case fetchFailed(String)
    case insertFailed(String)
    case updateFailed(String)
    case deleteFailed(String)
}
