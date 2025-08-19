import Foundation

final class DefaultFetchThemeOptionUseCase: FetchThemeOptionUseCase {
    private let userDefaultsRepository: UserDefaultsRepository

    init(userDefaultsRepository: UserDefaultsRepository) {
        self.userDefaultsRepository = userDefaultsRepository
    }

    func execute() async -> Result<ThemeOption, Error> {
        let raw = userDefaultsRepository.appThemeOption()
        guard let option = ThemeOption(rawValue: raw) else {
            return .success(.system)
        }

        return .success(option)
    }
}
