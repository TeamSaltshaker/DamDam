import Foundation

final class DefaultSaveThemeUseCase: SaveThemeUseCase {
    private let userDefaults: UserDefaults
    private let key = "appThemeOption"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func execute(_ option: ThemeOption) async -> Result<Void, Error> {
        userDefaults.set(option.rawValue, forKey: key)
        return .success(())
    }
}
