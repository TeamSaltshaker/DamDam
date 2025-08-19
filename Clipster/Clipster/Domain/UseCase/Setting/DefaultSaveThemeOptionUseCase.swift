import Foundation

final class DefaultSaveThemeOptionUseCase: SaveThemeOptionUseCase {
    private let userDefaultsRepository: UserDefaultsRepository

    init(userDefaultsRepository: UserDefaultsRepository) {
        self.userDefaultsRepository = userDefaultsRepository
    }

    func execute(_ option: ThemeOption) async -> Result<Void, Error> {
        userDefaultsRepository.setAppThemeOption(option.rawValue)
        await AppThemeManager.shared.apply(theme: option)
        return .success(())
    }
}
