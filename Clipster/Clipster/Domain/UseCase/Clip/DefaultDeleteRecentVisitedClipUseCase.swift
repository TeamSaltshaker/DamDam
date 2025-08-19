import Foundation

final class DefaultDeleteRecentVisitedClipUseCase: DeleteRecentVisitedClipUseCase {
    private let userDefaultsRepository: UserDefaultsRepository

    init(userDefaultsRepository: UserDefaultsRepository) {
        self.userDefaultsRepository = userDefaultsRepository
    }

    func execute(_ id: String) {
        var ids = userDefaultsRepository.recentVisitedClips()
        ids.removeAll { $0 == id }

        userDefaultsRepository.setRecentVisitedClips(ids)
    }
}
