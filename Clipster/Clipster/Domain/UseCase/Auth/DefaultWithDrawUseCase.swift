final class DefaultWithDrawUseCase: WithDrawUseCase {
    func execute() async -> Result<Bool, Error> {
        .success(true)
    }
}
