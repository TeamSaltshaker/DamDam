@testable import Clipster

final class StubPasteboardRepository: PasteboardRepository {
    var fetchURLStringResult: Result<String, PasteboardError>!

    func fetchURLString() async -> Result<String, PasteboardError> {
        return fetchURLStringResult
    }
}
