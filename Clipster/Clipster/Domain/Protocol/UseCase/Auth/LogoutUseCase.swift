protocol LogoutUseCase {
    func execute() async -> Result<Void, Error>
}
