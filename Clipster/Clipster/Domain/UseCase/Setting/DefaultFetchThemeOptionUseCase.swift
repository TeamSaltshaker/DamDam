import Foundation

final class DefaultFetchThemeOptionUseCase: FetchThemeOptionUseCase {
    private let userDefaults: UserDefaults
    private let key = "appThemeOption"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func execute() async -> Result<ThemeOption, Error> {
        let raw = userDefaults.integer(forKey: key)
        guard let option = ThemeOption(rawValue: raw) else {
            return .success(.system)
        }

        return .success(option)
    }
}
