import Foundation

final class DefaultSaveRecentVisitedClipUseCase: SaveRecentVisitedClipUseCase {
    func execute(_ id: UUID) async -> Result<Void, any Error> {
        .success(())
    }
}
