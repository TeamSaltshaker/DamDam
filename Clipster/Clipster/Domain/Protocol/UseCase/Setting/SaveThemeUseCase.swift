protocol SaveThemeUseCase {
    func execute(_ theme: ThemeOption) async -> Result<Void, Error>
}
