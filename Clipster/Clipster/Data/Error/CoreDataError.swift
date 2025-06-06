enum CoreDataError: Error {
    case entityNotFound
    case fetchFailed(String)
    case insertFailed(String)
    case updateFailed(String)
}
