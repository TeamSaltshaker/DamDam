protocol CheckLoginStatusUseCase {
    func execute() async -> Result<Bool, Error>
}
