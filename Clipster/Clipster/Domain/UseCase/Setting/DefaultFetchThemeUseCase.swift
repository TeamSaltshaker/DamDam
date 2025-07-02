import Foundation

final class DefaultFetchThemeUseCase: FetchThemeUseCase {
    private let userDefaults: UserDefaults
    private let key = "app_theme_option"

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
