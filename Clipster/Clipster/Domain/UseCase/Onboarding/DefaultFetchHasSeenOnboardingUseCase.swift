import Foundation

final class DefaultFetchHasSeenOnboardingUseCase: FetchHasSeenOnboardingUseCase {
    private let userDefaultsRepository: UserDefaultsRepository

    init(userDefaultsRepository: UserDefaultsRepository) {
        self.userDefaultsRepository = userDefaultsRepository
    }

    func execute() -> Bool {
        userDefaultsRepository.hasSeenOnboarding()
    }
}
