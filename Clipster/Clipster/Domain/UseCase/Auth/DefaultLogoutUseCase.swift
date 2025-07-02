final class DefaultLogoutUseCase: LogoutUseCase {
    func execute() async -> Result<Bool, Error> {
        .success(true)
    }
}
