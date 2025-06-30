import Foundation

final class DefaultDeleteRecentVisitedClipUseCase: DeleteRecentVisitedClipUseCase {
    func execute(_ id: UUID) async -> Result<Void, Error> {
        .success(())
    }
}
