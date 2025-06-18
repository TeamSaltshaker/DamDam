final class DefaultSanitizeFolderTitleUseCase: SanitizeFolderTitleUseCase {
    func execute(title: String) -> String {
        String(title.prefix(100))
    }
}
