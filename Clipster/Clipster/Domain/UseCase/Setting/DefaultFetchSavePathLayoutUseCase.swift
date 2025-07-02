import Foundation

final class DefaultFetchSavePathLayoutUseCase: FetchSavePathLayoutUseCase {
    private let userDefaults: UserDefaults
    private let key = "savePathOption"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func execute() async -> Result<SavePathOption, Error> {
        let raw = userDefaults.integer(forKey: key)
        guard let option = SavePathOption(rawValue: raw) else {
            return .success(.skip)
        }

        return .success(option)
    }
}
