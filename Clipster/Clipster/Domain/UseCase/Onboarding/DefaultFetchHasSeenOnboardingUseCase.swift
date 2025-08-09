import Foundation

final class DefaultFetchHasSeenOnboardingUseCase: FetchHasSeenOnboardingUseCase {
    private let userDefaultsRepository: UserDefaultsRepository

    init(userDefaultsRepository: UserDefaultsRepository) {
        self.userDefaultsRepository = userDefaultsRepository
    }

    func execute() -> Result<Bool, Error> {
        .success(userDefaultsRepository.hasSeenOnboarding())
    }
}
