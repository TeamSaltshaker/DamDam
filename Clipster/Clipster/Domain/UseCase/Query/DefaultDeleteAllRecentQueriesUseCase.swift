import Foundation

final class DefaultDeleteAllRecentQueriesUseCase: DeleteAllRecentQueriesUseCase {
    private let userDefaultsRepository: UserDefaultsRepository

    init(userDefaultsRepository: UserDefaultsRepository) {
        self.userDefaultsRepository = userDefaultsRepository
    }

    func execute() {
        userDefaultsRepository.removeRecentQueries()
    }
}
