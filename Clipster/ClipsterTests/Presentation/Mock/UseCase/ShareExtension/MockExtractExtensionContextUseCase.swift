@testable import Clipster
import Foundation
import UniformTypeIdentifiers

final class MockExtractExtensionContextUseCase: ExtractExtensionContextUseCase {
    private(set) var didCallExecute: Bool = false
    var shouldSucceed: Bool = true
    private(set) var receivedExtensionItems: [NSExtensionItem]?

    var executeResult: Result<URL, DomainError>!

    func execute(extensionItems: [NSExtensionItem]) async -> Result<URL, DomainError> {
        didCallExecute = true
        receivedExtensionItems = extensionItems

        return executeResult
    }
}
