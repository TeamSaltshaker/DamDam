import Foundation

final class DefaultDeleteClipUseCase: DeleteClipUseCase {
    func execute(id: UUID) async -> Result<Void, Error> {
        .success(())
    }
}
