import Foundation

final class DefaultSaveSavePathLayoutOptionUseCase: SaveSavePathLayoutOptionUseCase {
    private let userDefaultsRepository: UserDefaultsRepository

    init(userDefaultsRepository: UserDefaultsRepository) {
        self.userDefaultsRepository = userDefaultsRepository
    }

    func execute(_ option: SavePathOption) async -> Result<Void, Error> {
        userDefaultsRepository.setSavePathOption(option.rawValue)
        return .success(())
    }
}
