import Foundation

final class DefaultSaveSavePathVisibilityUseCase: SaveSavePathVisibilityUseCase {
    private let userDefaults: UserDefaults
    private let key = "save_path_option"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func execute(_ option: SavePathOption) async -> Result<Void, Error> {
        userDefaults.set(option.rawValue, forKey: key)
        return .success(())
    }
}
