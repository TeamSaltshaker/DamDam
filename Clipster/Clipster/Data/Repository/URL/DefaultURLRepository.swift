import Foundation
import WebKit

final class DefaultURLRepository: NSObject, WKNavigationDelegate, URLRepository {
    private var continuation: CheckedContinuation<Result<(ParsedURLMetadata?, Bool), any Error>, Never>?
    private var webView: WKWebView?
    private var originalURL: URL?
    private var timeoutTimer: Timer?

    func execute(url: URL) async -> Result<(ParsedURLMetadata?, Bool), any Error> {
        let finalURL = await resolveRedirectURL(initialURL: url)

        return await withCheckedContinuation { continuation in
            self.continuation = continuation
            self.originalURL = finalURL

            self.cleanupWebView()

            let config = WKWebViewConfiguration()
            let webViewFrame = CGRect(x: 0, y: 0, width: 375, height: 812)
            self.webView = WKWebView(frame: webViewFrame, configuration: config)
            self.webView?.navigationDelegate = self

            let request = URLRequest(url: finalURL)
            self.webView?.load(request)

            self.timeoutTimer = Timer.scheduledTimer(withTimeInterval: 20, repeats: false) { [weak self] _ in
                self?.handleTimeout()
            }
        }
    }

    func resolveRedirectURL(initialURL: URL) async -> URL {
        var request = URLRequest(url: initialURL)
        request.httpMethod = "HEAD"

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse,
               let finalURL = httpResponse.url {
                print("🎯 리디렉션 최종 URL: \(finalURL)")
                return finalURL
            }
        } catch {
            print("리디렉션 확인 실패: \(error)")
        }

        return initialURL
    }

    private func complete(with result: Result<(ParsedURLMetadata?, Bool), Error>) {
        guard let currentContinuation = continuation else { return }
        currentContinuation.resume(returning: result)
        cleanupWebView()
        continuation = nil
    }

    private func handleTimeout() {
        print("\(Self.self) WKWebView 로드 타임아웃 발생 URL: \(originalURL?.absoluteString ?? "N/A")")
        webView?.stopLoading()
        complete(with: .failure(URLError(.timedOut)))
    }

    private func cleanupWebView() {
        timeoutTimer?.invalidate()
        timeoutTimer = nil
        webView?.navigationDelegate = nil
        webView?.stopLoading()
        webView?.removeFromSuperview()
        webView = nil
        originalURL = nil
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation) {
        print("\(Self.self) WKWebView 로드 시작: \(webView.url?.absoluteString ?? "Unknown URL")")
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation, withError error: Error) {
        print("\(Self.self) WKWebView 초기 로드 실패: \(error.localizedDescription) URL: \(originalURL?.absoluteString ?? "N/A")")
        complete(with: .failure(error))
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
        print("\(Self.self) WKWebView 로드 완료: \(webView.url?.absoluteString ?? "Unknown URL")")

        timeoutTimer?.invalidate()
        timeoutTimer = nil

        Task {
            do {
                try await Task.sleep(for: .seconds(0.5))

                guard let htmlString = try await webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") as? String, !htmlString.isEmpty else {
                    print("\(Self.self) HTML 불러오기 실패")
                    self.complete(with: .success((nil, false)))
                    return
                }

                guard let url = webView.url?.absoluteURL else {
                    print("\(Self.self) WKWebView의 현재 URL이 없습니다.")
                    self.complete(with: .success((nil, false)))
                    return
                }

                let parsedDTO = try self.parseHTML(url: self.originalURL ?? url, html: htmlString)

                let topPortionRect = CGRect(x: 0, y: 0, width: webView.bounds.width, height: 400)
                let screenshotImage = await self.captureScreenshot(rect: topPortionRect)
                let screenshotData = screenshotImage?.pngData()

                let metadataDTOWithScreenshot = ParsedURLMetadataDTO(
                    url: parsedDTO.url,
                    title: parsedDTO.title,
                    thumbnailImageURL: parsedDTO.thumbnailImageURL,
                    screenshotData: screenshotData
                )

                let metadata = metadataDTOWithScreenshot.toEntity()
                self.complete(with: .success((metadata, true)))
            } catch {
                self.complete(with: .failure(error))
            }
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation, withError error: Error) {
        print("\(Self.self) WKWebView 로드 중 오류 발생: \(error.localizedDescription) URL: \(originalURL?.absoluteString ?? "N/A")")
        complete(with: .failure(error))
    }

    private func parseHTML(url: URL, html: String) throws -> ParsedURLMetadataDTO {
        let ogTitle = extractMetaContent(html: html, property: "og:title")
        let title = ogTitle ?? extractTitleTagContent(html: html) ?? "제목 없음"

        var thumbnailImageURL: String?

        if url.host?.contains("youtube") == true {
            if let videoID = extractYouTubeVideoID(from: url) {
                thumbnailImageURL = "https://img.youtube.com/vi/\(videoID)/hqdefault.jpg"
            }
        }

        return ParsedURLMetadataDTO(
            url: url,
            title: title,
            thumbnailImageURL: URL(string: thumbnailImageURL ?? ""),
            screenshotData: nil
        )
    }

    private func captureScreenshot(rect: CGRect? = nil) async -> UIImage? {
        guard let webView = self.webView else {
            print("\(Self.self) WKWebView 인스턴스가 없어 스크린샷을 찍을 수 없습니다.")
            return nil
        }

        return await withCheckedContinuation { continuation in
            let configuration = WKSnapshotConfiguration()

            if let rect = rect {
                configuration.rect = rect // 캡처할 특정 영역 설정
            }

            webView.takeSnapshot(with: configuration) { image, error in
                if let error = error {
                    print("\(Self.self) 스크린샷 캡처 실패: \(error.localizedDescription)")
                    continuation.resume(returning: nil)
                } else if let image = image {
                    print("\(Self.self) 스크린샷 캡처 성공.")
                    continuation.resume(returning: image)
                } else {
                    print("\(Self.self) 스크린샷 캡처 결과 이미지가 없습니다.")
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}

private extension DefaultURLRepository {
    func extractMetaContent(html: String, property: String) -> String? {
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

    func extractTitleTagContent(html: String) -> String? {
        let pattern = "<title[^>]*>([^<]*)</title>"
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
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            if components.host?.contains("youtube.com") == true || components.host?.contains("m.youtube.com") == true {
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
}
