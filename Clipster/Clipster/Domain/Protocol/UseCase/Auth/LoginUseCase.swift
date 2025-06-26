protocol LoginUseCase {
    func execute(type: LoginType) async -> Result<String, Error>
}
