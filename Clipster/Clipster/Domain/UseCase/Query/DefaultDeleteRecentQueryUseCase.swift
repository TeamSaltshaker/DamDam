import Foundation

final class DefaultDeleteRecentQueryUseCase: DeleteRecentQueryUseCase {
    private let userDefaultsRepository: UserDefaultsRepository

    init(userDefaultsRepository: UserDefaultsRepository) {
        self.userDefaultsRepository = userDefaultsRepository
    }

    func execute(_ query: String) {
        var queries = userDefaultsRepository.recentQueries()
        queries.removeAll { $0 == query }

        userDefaultsRepository.setRecentQueries(queries)
    }
}
