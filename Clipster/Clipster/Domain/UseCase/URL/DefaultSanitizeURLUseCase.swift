import Foundation

final class DefaultSanitizeURLUseCase: SanitizeURLUseCase {
    func execute(urlString: String) -> Result<URL, URLValidationError> {
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
}
