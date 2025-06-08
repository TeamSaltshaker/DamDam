import Foundation

final class DefaultURLMetadataRepository: URLMetadataRepository {
    func execute(url: URL) async -> Result<ParsedURLMetadata, any Error> {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                return .failure(URLError(.badServerResponse))
            }
            let html = String(data: data, encoding: .utf8)
            let urlMetadata = try parseHTML(url: url, html: html ?? "")
            return .success(urlMetadata.toEntity())
        } catch {
            print(error)
            return .failure(error)
        }
    }
}

private extension DefaultURLMetadataRepository {
    func parseHTML(url: URL, html: String) throws -> ParsedURLMetadataDTO {
        ParsedURLMetadataDTO(
            url: url,
            title: extractMetaContent(html: html, property: "og:title") ?? "",
            thumbnailImage: extractMetaContent(html: html, property: "og:image") ?? ""
        )
    }

    func extractMetaContent(html: String, property: String) -> String? {
        let pattern = "<meta[^>]*property=[\"']\(property)[\"'][^>]*content=[\"']([^\"']*)[\"'][^>]*>"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return nil
        }

        let range = NSRange(html.startIndex..., in: html)
        guard let match = regex.firstMatch(in: html, options: [], range: range),
              let contentRange = Range(match.range(at: 1), in: html) else {
            return nil
        }

        return String(html[contentRange])
    }
}
