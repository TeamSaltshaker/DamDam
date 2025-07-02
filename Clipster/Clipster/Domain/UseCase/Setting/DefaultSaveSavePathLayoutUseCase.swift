import Foundation

final class DefaultSaveSavePathLayoutUseCase: SaveSavePathLayoutUseCase {
    private let userDefaults: UserDefaults
    private let key = "savePathOption"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func execute(_ option: SavePathOption) async -> Result<Void, Error> {
        userDefaults.set(option.rawValue, forKey: key)
        return .success(())
    }
}
