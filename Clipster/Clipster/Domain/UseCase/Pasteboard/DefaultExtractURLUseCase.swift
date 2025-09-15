import Foundation

final class DefaultExtractURLUseCase: ExtractURLUseCase {
    let pasteboardRepository: PasteboardRepository

    init(pasteboardRepository: PasteboardRepository) {
        self.pasteboardRepository = pasteboardRepository
    }

    func execute() async -> Result<URL, PasteboardError> {
        let result = await pasteboardRepository.fetchURLString()

        return result.flatMap { pastedString in
            guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
                print("\(Self.self) NSDataDetector 생성 중 오류 발생")
                return .failure(.failedInitNSDataDetector)
            }

            guard let url = detector.firstMatch(
                in: pastedString,
                range: NSRange(location: 0, length: pastedString.utf16.count)
            )?.url else {
                print("\(Self.self) URL 추출 중 오류 발생")
                return .failure(.failedExtractURL)
            }

            return .success(url)
        }
    }
}
