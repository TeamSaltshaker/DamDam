import Foundation

final class DefaultFetchRecentVisitedClipsUseCase: FetchRecentVisitedClipsUseCase {
    private let clipRepository: ClipRepository
    private let userDefaults: UserDefaults
    private let key = "recentVisitedClips"

    init(clipRepository: ClipRepository, userDefaults: UserDefaults) {
        self.clipRepository = clipRepository
        self.userDefaults = userDefaults
    }

    func execute() async -> Result<[Clip], Error> {
        let stringIDs = userDefaults.stringArray(forKey: key) ?? []
        let ids = stringIDs.compactMap { UUID(uuidString: $0) }

        guard !ids.isEmpty else {
            return .success([])
        }

        return await clipRepository.fetchRecentVisitedClips(for: ids).mapError { $0 as Error }
    }
}
