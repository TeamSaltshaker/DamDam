import Foundation

final class DefaultParseURLUseCase: ParseURLUseCase {
    let urlRepository: URLRepository

    init(urlMetaRepository: URLRepository) {
        self.urlRepository = urlMetaRepository
    }

    func execute(urlString: String) async -> Result<(URLMetadata?, Bool), URLValidationError> {
        guard let sanitizeURL = try? sanitizeURL(urlString: urlString).get() else {
            return .failure(.badURL)
        }

        let resolveFinalURL = await urlRepository.resolveRedirectURL(initialURL: sanitizeURL)

        let htmlResult = await urlRepository.fetchHTML(from: resolveFinalURL)

        switch htmlResult {
        case .success(let (html, screenshotData)):
            let parsedMetadata = createParsedURLMetadata(url: sanitizeURL, html: html, screenshotData: screenshotData)
            return .success((parsedMetadata, true))

        case .failure(let error):
            return .failure(error)
        }
    }
}

extension DefaultParseURLUseCase {
    func sanitizeURL(urlString: String) -> Result<URL, URLValidationError> {
        let lowercased = urlString.lowercased()
        let correctedURLString: String

        if lowercased.hasPrefix("https://") || lowercased.hasPrefix("http://") {
            correctedURLString = urlString
        } else if lowercased.hasPrefix("https:/") || lowercased.hasPrefix("http:/") {
            correctedURLString = lowercased.replacingOccurrences(of: "https:/", with: "https://")
                .replacingOccurrences(of: "http:/", with: "https://")
        } else if lowercased.hasPrefix("https:")  || lowercased.hasPrefix("http:") {
            correctedURLString =  lowercased.replacingOccurrences(of: "https:", with: "https://")
                .replacingOccurrences(of: "http:", with: "http://")
        } else {
            correctedURLString = "https://\(urlString)"
        }

        guard correctedURLString != "https://" || correctedURLString != "http://" else {
            return .failure(.badURL)
        }

        guard let url = URL(string: correctedURLString) else {
            return .failure(.badURL)
        }

        guard let host = url.host, host.contains(".") else {
            return .failure(.badURL)
        }
        return .success(url)
    }

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
