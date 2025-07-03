protocol FetchThemeOptionUseCase {
    func execute() async -> Result<ThemeOption, Error>
}
