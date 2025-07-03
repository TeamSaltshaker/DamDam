final class DefaultCheckLoginStatusUseCase: CheckLoginStatusUseCase {
    func execute() async -> Result<Bool, Error> {
        .success(true)
    }
}
