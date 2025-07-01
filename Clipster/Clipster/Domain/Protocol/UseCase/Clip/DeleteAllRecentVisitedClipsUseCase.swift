import Foundation

protocol DeleteAllRecentVisitedClipsUseCase {
    func execute() async -> Result<Void, Error>
}
