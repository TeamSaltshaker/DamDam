protocol WithdrawUseCase {
    func execute() async -> Result<Void, Error>
}
