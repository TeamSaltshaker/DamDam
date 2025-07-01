import Foundation

protocol SaveRecentVisitedClipUseCase {
    func execute(_ id: UUID) async -> Result<Void, Error>
}
