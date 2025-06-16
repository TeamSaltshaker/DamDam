import Foundation

final class DefaultURLValidationRepository: URLValidationRepository {
    func execute(url: URL) async -> Result<Bool, Error> {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                return .failure(URLError(.badServerResponse))
            }
            let html = String(data: data, encoding: .utf8)
            return .success(html != nil)
        } catch {
            return .failure(error)
        }
    }
}
