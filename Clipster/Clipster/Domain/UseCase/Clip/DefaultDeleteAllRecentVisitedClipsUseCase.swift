import Foundation

final class DefaultDeleteAllRecentVisitedClipsUseCase: DeleteAllRecentVisitedClipsUseCase {
    private let userDefaults: UserDefaults
    private let key = "recentVisitedClips"

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    func execute() {
        userDefaults.removeObject(forKey: key)
    }
}
