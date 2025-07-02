protocol WithDrawUseCase {
    func execute() async -> Result<Bool, Error>
}
