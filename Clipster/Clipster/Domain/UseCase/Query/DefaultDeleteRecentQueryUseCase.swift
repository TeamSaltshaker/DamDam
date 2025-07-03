import Foundation

final class DefaultDeleteRecentQueryUseCase: DeleteRecentQueryUseCase {
    private let userDefaults: UserDefaults
    private let key = "recentQueries"

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    func execute(_ query: String) {
        var queries = userDefaults.stringArray(forKey: key) ?? []
        queries.removeAll { $0 == query }

        userDefaults.set(queries, forKey: key)
    }
}
