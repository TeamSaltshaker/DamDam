import Foundation

final class DefaultFetchRecentVisitedClipsUseCase: FetchRecentVisitedClipsUseCase {
    private let clipRepository: ClipRepository
    private let userDefaultsRepository: UserDefaultsRepository

    init(clipRepository: ClipRepository, userDefaultsRepository: UserDefaultsRepository) {
        self.clipRepository = clipRepository
        self.userDefaultsRepository = userDefaultsRepository
    }

    func execute() async -> Result<[Clip], Error> {
        let stringIDs = userDefaultsRepository.recentVisitedClips()
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
