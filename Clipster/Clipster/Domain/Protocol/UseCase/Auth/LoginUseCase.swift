protocol LoginUseCase {
    func execute(type: LoginType) async -> Result<Void, Error>
}
