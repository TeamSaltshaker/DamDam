import Foundation

final class DefaultFetchRecentQueriesUseCase: FetchRecentQueriesUseCase {
    private let userDefaultsRepository: UserDefaultsRepository

    init(userDefaultsRepository: UserDefaultsRepository) {
        self.userDefaultsRepository = userDefaultsRepository
    }

    func execute() -> [String] {
        userDefaultsRepository.recentQueries()
    }
}
