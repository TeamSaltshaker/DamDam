import Foundation

final class DefaultUpdateHasSeenOnboardingUseCase: UpdateHasSeenOnboardingUseCase {
    private let userDefaultsRepository: UserDefaultsRepository

    init(userDefaultsRepository: UserDefaultsRepository) {
        self.userDefaultsRepository = userDefaultsRepository
    }

    func execute(_ hasSeen: Bool) {
        userDefaultsRepository.setHasSeenOnboarding(hasSeen)
    }
}
