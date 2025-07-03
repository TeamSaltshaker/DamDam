final class DefaultWithdrawUseCase: WithdrawUseCase {
    func execute() async -> Result<Bool, Error> {
        .success(true)
    }
}
