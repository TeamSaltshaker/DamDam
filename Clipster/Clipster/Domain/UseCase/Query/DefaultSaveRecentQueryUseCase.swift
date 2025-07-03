import Foundation

final class DefaultSaveRecentQueryUseCase: SaveRecentQueryUseCase {
    private let userDefaults: UserDefaults
    private let key = "recentQueries"

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    func execute(_ query: String) {
        var queries = userDefaults.stringArray(forKey: key) ?? []
        queries.removeAll { $0 == query }
        queries.insert(query, at: 0)
        queries = Array(queries.prefix(10))

        userDefaults.set(queries, forKey: key)
    }
}
