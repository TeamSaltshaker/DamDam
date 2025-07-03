import Foundation

final class DefaultFetchRecentQueriesUseCase: FetchRecentQueriesUseCase {
    private let userDefaults: UserDefaults
    private let key = "recentQueries"

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    func execute() -> [String] {
        userDefaults.stringArray(forKey: key) ?? []
    }
}
