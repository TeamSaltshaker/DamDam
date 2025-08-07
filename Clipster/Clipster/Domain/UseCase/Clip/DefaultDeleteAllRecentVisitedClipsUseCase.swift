import Foundation

final class DefaultDeleteAllRecentVisitedClipsUseCase: DeleteAllRecentVisitedClipsUseCase {
    private let userDefaultsRepository: UserDefaultsRepository

    init(userDefaultsRepository: UserDefaultsRepository) {
        self.userDefaultsRepository = userDefaultsRepository
    }

    func execute() {
        userDefaultsRepository.removeRecentVisitedClips()
    }
}
