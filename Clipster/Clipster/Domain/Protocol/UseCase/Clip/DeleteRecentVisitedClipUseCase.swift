import Foundation

protocol DeleteRecentVisitedClipUseCase {
    func execute(_ id: UUID) async -> Result<Void, Error>
}
