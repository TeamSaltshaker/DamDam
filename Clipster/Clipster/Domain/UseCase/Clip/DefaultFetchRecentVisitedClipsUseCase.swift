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

        let result = await clipRepository.fetchRecentVisitedClips(for: ids)

        switch result {
        case .success(let clips):
            let clipDictionary = Dictionary(uniqueKeysWithValues: clips.map { ($0.id, $0) })
            let sortedClips = ids.compactMap { clipDictionary[$0] }
            return .success(sortedClips)
        case .failure(let error):
            return .failure(error)
        }
    }
}
