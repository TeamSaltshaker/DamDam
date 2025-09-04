protocol PasteboardRepository {
    func fetchURLString() async -> Result<String, PasteboardError>
}
