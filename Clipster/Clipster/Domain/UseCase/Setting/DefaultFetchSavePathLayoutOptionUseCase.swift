import Foundation

final class DefaultFetchSavePathLayoutOptionUseCase: FetchSavePathLayoutOptionUseCase {
    private let userDefaultsRepository: UserDefaultsRepository

    init(userDefaultsRepository: UserDefaultsRepository) {
        self.userDefaultsRepository = userDefaultsRepository
    }

    func execute() async -> Result<SavePathOption, Error> {
        let raw = userDefaultsRepository.savePathOption()
        guard let option = SavePathOption(rawValue: raw) else {
            return .success(.expand)
        }

        return .success(option)
    }
}
