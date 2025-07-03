import Foundation
import UniformTypeIdentifiers

final class DefaultExtractExtensionContextUseCase: ExtractExtensionContextUseCase {
    func execute(extensionItems: [NSExtensionItem]) async -> Result<URL, DomainError> {
        for item in extensionItems {
            guard let attachments = item.attachments else { continue }

            for provider in attachments {
                for typeIdentifier in provider.registeredTypeIdentifiers {
                    do {
                        let item = try await provider.loadItemAsync(forTypeIdentifier: typeIdentifier)
                        if let url = extractURL(from: item) {
                            return .success(url)
                        }
                    } catch {
                        continue
                    }
                }
            }
        }
        return .failure(.unknownError)
    }
}

private extension DefaultExtractExtensionContextUseCase {
    func extractURL(from item: NSSecureCoding?) -> URL? {
        if let url = item as? URL {
            return url
        } else if let string = item as? String {
            return extractFirstURL(from: string)
        } else if let data = item as? Data,
                  let string = String(data: data, encoding: .utf8) {
            return extractFirstURL(from: string)
        }
        return nil
    }

    func extractFirstURL(from string: String) -> URL? {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector?.matches(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count))

        return matches?.first?.url
    }
}

extension NSItemProvider {
    func loadItemAsync(forTypeIdentifier typeIdentifier: String) async throws -> NSSecureCoding? {
        try await withCheckedThrowingContinuation { continuation in
            self.loadItem(forTypeIdentifier: typeIdentifier, options: nil) { item, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: item)
                }
            }
        }
    }
}
