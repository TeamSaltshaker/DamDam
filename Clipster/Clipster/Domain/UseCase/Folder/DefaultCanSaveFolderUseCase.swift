final class DefaultCanSaveFolderUseCase: CanSaveFolderUseCase {
    func execute(title: String) -> Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
