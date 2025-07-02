protocol LogoutUseCase {
    func execute() async -> Result<Bool, Error>
}
