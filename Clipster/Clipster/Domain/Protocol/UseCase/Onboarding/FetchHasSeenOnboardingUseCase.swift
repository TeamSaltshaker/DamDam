protocol FetchHasSeenOnboardingUseCase {
    func execute() -> Result<Bool, Error>
}
