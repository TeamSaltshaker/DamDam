import Foundation

final class DefaultDeleteRecentVisitedClipUseCase: DeleteRecentVisitedClipUseCase {
    private let userDefaults: UserDefaults
    private let key = "recentVisitedClips"

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    func execute(_ id: String) {
        var ids = userDefaults.stringArray(forKey: key) ?? []
        ids.removeAll { $0 == id }

        userDefaults.set(ids, forKey: key)
    }
}
