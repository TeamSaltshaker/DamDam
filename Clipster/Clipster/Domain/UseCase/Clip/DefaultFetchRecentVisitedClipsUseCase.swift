import Foundation
final class DefaultFetchRecentVisitedClipsUseCase: FetchRecentVisitedClipsUseCase {
    private let clipRepository: ClipRepository

    init(clipRepository: ClipRepository) {
        self.clipRepository = clipRepository
    }

    func execute() async -> Result<[Clip], any Error> {
        .success([])
    }
}
