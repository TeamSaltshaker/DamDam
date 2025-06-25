final class DefaultSearchFoldersUseCase: SearchFoldersUseCase {
    func execute(query: String, in folders: [Folder]) -> [Folder] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedQuery.isEmpty {
            return []
        }

        return folders.filter {
            $0.title.localizedCaseInsensitiveContains(query)
        }
    }
}
