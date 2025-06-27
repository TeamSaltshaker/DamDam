import Foundation

final class DefaultDeleteAllRecentVisitedClipsUseCase: DeleteAllRecentVisitedClipsUseCase {
    func execute() async -> Result<Void, any Error> {
        .success(())
    }
}
