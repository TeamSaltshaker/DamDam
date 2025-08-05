protocol UserDefaultsStorage {
    func hasSeenOnboarding() -> Bool
    func setHasSeenOnboarding(_ hasSeen: Bool)

    func recentVisitedClips() -> [String]
    func setRecentVisitedClips(_ ids: [String])
    func removeRecentVisitedClips()

    func recentQueries() -> [String]
    func setRecentQueries(_ queries: [String])
    func removeRecentQueries()

    func clipSortOption() -> String?
    func setClipSortOption(_ option: String)

    func folderSortOption() -> String?
    func setFolderSortOption(_ option: String)

    func savePathOption() -> Int
    func setSavePathOption(_ option: Int)

    func appThemeOption() -> Int
    func setAppThemeOption(_ option: Int)
}
