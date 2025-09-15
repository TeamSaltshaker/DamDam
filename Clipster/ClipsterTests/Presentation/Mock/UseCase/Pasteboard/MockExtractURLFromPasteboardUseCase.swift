@testable import Clipster
import Foundation

final class MockExtractURLFromPasteboardUseCase: ExtractURLFromPasteboardUseCase {
    private(set) var didCallExecute: Bool = false
    var executeResult: Result<URL, PasteboardError>!

    func execute() async -> Result<URL, PasteboardError> {
        didCallExecute = true

        return executeResult
    }
}
