import Foundation

final class DefaultDeleteAllRecentQueriesUseCase: DeleteAllRecentQueriesUseCase {
    private let userDefaults: UserDefaults
    private let key = "recentQueries"

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    func execute() {
        userDefaults.removeObject(forKey: key)
    }
}
