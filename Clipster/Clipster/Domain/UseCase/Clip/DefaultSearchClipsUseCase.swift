final class DefaultSearchClipsUseCase: SearchClipsUseCase {
    func execute(query: String, in clips: [Clip]) -> [Clip] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedQuery.isEmpty {
            return []
        }

        return clips.filter {
            $0.urlMetadata.url.absoluteString.localizedCaseInsensitiveContains(trimmedQuery) ||
            $0.urlMetadata.title.localizedCaseInsensitiveContains(query) ||
            $0.memo.localizedCaseInsensitiveContains(query)
        }
    }
}
