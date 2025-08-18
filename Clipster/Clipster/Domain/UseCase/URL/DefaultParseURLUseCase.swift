import Foundation

final class DefaultParseURLUseCase: ParseURLUseCase {
    let urlRepository: URLRepository

    init(urlMetaRepository: URLRepository) {
        self.urlRepository = urlMetaRepository
    }

    func execute(url: URL) async -> Result<(URLMetadata?, Bool), URLValidationError> {
        let resolveFinalURL = await urlRepository.resolveRedirectURL(initialURL: url)

        let htmlResult = await urlRepository.fetchHTML(from: resolveFinalURL)

        switch htmlResult {
        case .success(let html):
            let screenshotData = await urlRepository.captureScreenshot(rect: nil)
            let parsedMetadata = createParsedURLMetadata(url: url, html: html, screenshotData: screenshotData)
            return .success((parsedMetadata, true))

        case .failure(let error):
            return .failure(error)
        }
    }
}

extension DefaultParseURLUseCase {
    func createParsedURLMetadata(url: URL, html: String, screenshotData: Data?) -> URLMetadata {
        let ogTitle = extractOGContent(html: html, property: "og:title")
        let title = ogTitle ?? extractHTMLTagContent(html: html, property: "title") ?? "제목 없음"

        let ogDescription = extractOGContent(html: html, property: "og:description") ?? "내용 없음"

        var thumbnailImageURL: String?

        if let videoID = extractYouTubeVideoID(from: url) {
            thumbnailImageURL = makeYouTubeThumbnailURL(videoID: videoID)
        }

        return URLMetadata(
            url: url,
            title: title.isEmpty ? url.absoluteString : title,
            description: ogDescription,
            thumbnailImageURL: URL(string: thumbnailImageURL ?? ""),
            screenshotData: screenshotData
        )
    }

    func extractOGContent(html: String, property: String) -> String? {
        let pattern = "<meta[^>]*?(?:property|name)=[\"']\(NSRegularExpression.escapedPattern(for: property))[\"'][^>]*?content=[\"']([^\"']*)[\"'][^>]*?>"

        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return nil
        }

        let range = NSRange(html.startIndex..., in: html)
        guard let match = regex.firstMatch(in: html, options: [], range: range),
              match.numberOfRanges > 1,
              let contentRange = Range(match.range(at: 1), in: html) else {
            return nil
        }

        return String(html[contentRange])
    }

    func extractHTMLTagContent(html: String, property: String) -> String? {
        let pattern = "<\(property)[^>]*>([^<]*)</\(property)>"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return nil
        }

        let range = NSRange(html.startIndex..., in: html)
        guard let match = regex.firstMatch(in: html, options: [], range: range),
              match.numberOfRanges > 1,
              let contentRange = Range(match.range(at: 1), in: html) else {
            return nil
        }
        return String(html[contentRange]).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func extractYouTubeVideoID(from url: URL) -> String? {
        if let host = url.host(percentEncoded: false), !host.contains("youtu") {
            return nil
        }

        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            if components.host?.contains("youtube.com") == true {
                if let queryItems = components.queryItems {
                    for item in queryItems {
                        if item.name == "v", let videoID = item.value {
                            return videoID
                        }
                    }
                }
            } else if components.host?.contains("youtu.be") == true {
                let pathComponents = components.path.split(separator: "/")
                if let videoID = pathComponents.last, !videoID.isEmpty {
                    return String(videoID)
                }
            }
        }
        return nil
    }

    func makeYouTubeThumbnailURL(videoID: String) -> String {
        "https://img.youtube.com/vi/\(videoID)/hqdefault.jpg"
    }
}
