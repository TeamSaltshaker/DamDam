import UIKit

final class DefaultExtractURLFromPasteboardUseCase: ExtractURLFromPasteboardUseCase {
    func execute() async -> URL? {
        guard let patterns = try? await UIPasteboard.general.detectedPatterns(for: [\.probableWebURL]) else {
            print("\(Self.self) 클립보드에 감지된 URL이 없습니다.")
            return nil
        }

        guard patterns.contains(\.probableWebURL), let pastedString = UIPasteboard.general.string else {
            print("\(Self.self) 클립보드에서 URL을 가져올 수 없습니다.")
            return nil
        }

        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            print("\(Self.self) NSDataDetector 생성 중 오류 발생")
            return nil
        }
        return detector.firstMatch(in: pastedString, range: NSRange(location: 0, length: pastedString.utf16.count))?.url
    }
}
