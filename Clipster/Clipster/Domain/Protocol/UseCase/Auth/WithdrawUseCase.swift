protocol WithdrawUseCase {
    func execute() async -> Result<Bool, Error>
}
