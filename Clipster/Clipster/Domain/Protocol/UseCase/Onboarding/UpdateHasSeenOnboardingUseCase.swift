protocol UpdateHasSeenOnboardingUseCase {
    func execute(_ hasSeen: Bool) -> Result<Void, Error>
}
