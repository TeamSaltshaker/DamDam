import Foundation

enum DummyError: Error {
    case notImplemented
}

final class DefaultFetchFolderUseCase: FetchFolderUseCase {
    func execute(parentFolderID: UUID?) async -> Result<Folder, Error> {
        .failure(DummyError.notImplemented)
    }
}
