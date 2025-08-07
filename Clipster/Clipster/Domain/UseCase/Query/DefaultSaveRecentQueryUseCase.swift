import Foundation

final class DefaultSaveRecentQueryUseCase: SaveRecentQueryUseCase {
    private let userDefaultsRepository: UserDefaultsRepository

    init(userDefaultsRepository: UserDefaultsRepository) {
        self.userDefaultsRepository = userDefaultsRepository
    }

    func execute(_ query: String) {
        var queries = userDefaultsRepository.recentQueries()
        queries.removeAll { $0 == query }
        queries.insert(query, at: 0)
        queries = Array(queries.prefix(10))

        userDefaultsRepository.setRecentQueries(queries)
    }
}
