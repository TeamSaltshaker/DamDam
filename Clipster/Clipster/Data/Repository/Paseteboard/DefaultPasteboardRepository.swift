import UIKit

final class DefaultPasteboardRepository: PasteboardRepository {
    func fetchURLString() async -> Result<String, PasteboardError> {
        guard let patterns = try? await UIPasteboard.general.detectedPatterns(for: [\.probableWebURL]) else {
            print("\(Self.self) 클립보드에 감지된 URL이 없습니다.")
            return .failure(.notDetectedURL)
        }

        guard patterns.contains(\.probableWebURL), let pastedString = UIPasteboard.general.string else {
            print("\(Self.self) 클립보드의 URL을 가져올 수 없습니다.")
            return .failure(.failedToRead)
        }

        return .success(pastedString)
    }
}
