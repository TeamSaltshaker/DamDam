import Foundation

protocol ExtractExtensionContextUseCase {
    func execute(extensionItems: [NSExtensionItem]) async -> Result<URL, DomainError>
}
