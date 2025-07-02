protocol SaveThemeOptionUseCase {
    func execute(_ theme: ThemeOption) async -> Result<Void, Error>
}
