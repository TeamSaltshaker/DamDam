import Foundation

final class DefaultFetchClipUseCase: FetchClipUseCase {
    func execute(id: UUID) async -> Result<Clip, any Error> {
        .failure(DummyError.notImplemented)
    }
}
