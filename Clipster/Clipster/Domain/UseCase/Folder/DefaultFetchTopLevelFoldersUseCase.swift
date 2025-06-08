import Foundation

enum DummyError: Error {
    case notImplemented
}

final class DefaultFetchTopLevelFoldersUseCase: FetchTopLevelFoldersUseCase {
    func execute(parentFolderID: UUID?) async -> Result<Folder, Error> {
        .failure(DummyError.notImplemented)
    }
}
