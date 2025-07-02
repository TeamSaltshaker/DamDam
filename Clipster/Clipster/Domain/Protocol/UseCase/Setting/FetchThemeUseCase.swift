protocol FetchThemeUseCase {
    func execute() async -> Result<ThemeOption, Error>
}
