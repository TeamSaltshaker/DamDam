import Foundation

final class DefaultUserDefaultsRepository: UserDefaultsRepository {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    func hasSeenOnboarding() -> Bool {
        userDefaults.bool(forKey: UserDefaultsKeys.hasSeenOnboarding.rawValue)
    }

    func setHasSeenOnboarding(_ hasSeen: Bool) {
        userDefaults.set(hasSeen, forKey: UserDefaultsKeys.hasSeenOnboarding.rawValue)
    }

    func recentVisitedClips() -> [String] {
        userDefaults.stringArray(forKey: UserDefaultsKeys.recentVisitedClips.rawValue) ?? []
    }

    func setRecentVisitedClips(_ ids: [String]) {
        userDefaults.set(ids, forKey: UserDefaultsKeys.recentVisitedClips.rawValue)
    }

    func removeRecentVisitedClips() {
        userDefaults.removeObject(forKey: UserDefaultsKeys.recentVisitedClips.rawValue)
    }

    func recentQueries() -> [String] {
        userDefaults.stringArray(forKey: UserDefaultsKeys.recentQueries.rawValue) ?? []
    }

    func setRecentQueries(_ queries: [String]) {
        userDefaults.set(queries, forKey: UserDefaultsKeys.recentQueries.rawValue)
    }

    func removeRecentQueries() {
        userDefaults.removeObject(forKey: UserDefaultsKeys.recentQueries.rawValue)
    }

    func clipSortOption() -> String? {
        userDefaults.string(forKey: UserDefaultsKeys.clipSortOption.rawValue)
    }

    func setClipSortOption(_ option: String) {
        userDefaults.set(option, forKey: UserDefaultsKeys.clipSortOption.rawValue)
    }

    func folderSortOption() -> String? {
        userDefaults.string(forKey: UserDefaultsKeys.folderSortOption.rawValue)
    }

    func setFolderSortOption(_ option: String) {
        userDefaults.set(option, forKey: UserDefaultsKeys.folderSortOption.rawValue)
    }

    func savePathOption() -> Int {
        userDefaults.integer(forKey: UserDefaultsKeys.savePathOption.rawValue)
    }

    func setSavePathOption(_ option: Int) {
        userDefaults.set(option, forKey: UserDefaultsKeys.savePathOption.rawValue)
    }

    func appThemeOption() -> Int {
        userDefaults.integer(forKey: UserDefaultsKeys.appThemeOption.rawValue)
    }

    func setAppThemeOption(_ option: Int) {
        userDefaults.set(option, forKey: UserDefaultsKeys.appThemeOption.rawValue)
    }
}
