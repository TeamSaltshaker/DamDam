import Foundation
import WebKit

final class DefaultURLRepository: NSObject, WKNavigationDelegate, URLRepository {
    private var continuation: CheckedContinuation<Result<String, URLValidationError>, Never>?
    private var webView: WKWebView?
    private var originalURL: URL?
    private var timeoutTimer: Timer?

    func fetchHTML(from url: URL) async -> Result<String, URLValidationError> {
        await withCheckedContinuation { continuation in
            self.cleanupWebView()

            self.continuation = continuation
            self.originalURL = url

            let config = WKWebViewConfiguration()
            let webViewFrame = CGRect(x: 0, y: 0, width: 375, height: 812)
            self.webView = WKWebView(frame: webViewFrame, configuration: config)
            self.webView?.navigationDelegate = self

            let request = URLRequest(url: url)
            self.webView?.load(request)

            self.timeoutTimer = Timer.scheduledTimer(withTimeInterval: 20, repeats: false) { [weak self] _ in
                self?.handleTimeout()
            }
        }
    }

    func resolveRedirectURL(initialURL: URL) async -> URL {
        var request = URLRequest(url: initialURL)
        request.httpMethod = "get"

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse,
               let finalURL = httpResponse.url {
                print("\(Self.self) 리디렉션 최종 URL: \(finalURL)")
                return finalURL
            }
        } catch {
            print("\(Self.self) 리디렉션 확인 실패: \(error)")
        }

        return initialURL
    }

    func captureScreenshot(rect: CGRect? = nil) async -> Data? {
        guard let webView = self.webView else {
            print("\(Self.self) WKWebView 인스턴스가 없어 스크린샷을 찍을 수 없습니다.")
            return nil
        }

        return await withCheckedContinuation { continuation in
            let configuration = WKSnapshotConfiguration()

            if let rect = rect {
                configuration.rect = rect
            }

            webView.takeSnapshot(with: configuration) { image, error in
                if let error = error {
                    print("\(Self.self) 스크린샷 캡처 실패: \(error.localizedDescription)")
                    continuation.resume(returning: nil)
                } else if let image = image {
                    print("\(Self.self) 스크린샷 캡처 성공.")
                    continuation.resume(returning: image.jpegData(compressionQuality: 0.5))
                } else {
                    print("\(Self.self) 스크린샷 캡처 결과 이미지가 없습니다.")
                    continuation.resume(returning: nil)
                }
                self.cleanupWebView()
            }
        }
    }
}

extension DefaultURLRepository {
    private func complete(with result: Result<String, URLValidationError>) {
        guard let currentContinuation = continuation else { return }
        currentContinuation.resume(returning: result)
        continuation = nil
    }

    private func handleTimeout() {
        print("\(Self.self) WKWebView 로드 타임아웃 발생 URL: \(originalURL?.absoluteString ?? "N/A")")
        webView?.stopLoading()
        complete(with: .failure(.timeOut))
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
        complete(with: .failure(.unsupportedURL))
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
        print("\(Self.self) WKWebView 로드 완료: \(webView.url?.absoluteString ?? "Unknown URL")")

        timeoutTimer?.invalidate()
        timeoutTimer = nil

        Task {
            do {
                while true {
                    let readyState = try await webView.evaluateJavaScript("document.readyState") as? String
                    if readyState == "complete" { break }
                    try await Task.sleep(for: .milliseconds(200))
                }

                guard let htmlString = try await webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") as? String, !htmlString.isEmpty else {
                    print("\(Self.self) HTML 불러오기 실패")
                    self.complete(with: .failure(.emptyHTMLContent))
                    return
                }

                guard webView.url?.absoluteURL != nil else {
                    print("\(Self.self) WKWebView의 현재 URL이 없습니다.")
                    self.complete(with: .failure(.notFoundedWKURL))
                    return
                }

                self.complete(with: .success(htmlString))
            } catch {
                self.complete(with: .failure(.unknown))
            }
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation, withError error: Error) {
        print("\(Self.self) WKWebView 로드 중 오류 발생: \(error.localizedDescription) URL: \(originalURL?.absoluteString ?? "N/A")")
        complete(with: .failure(.unsupportedURL))
    }
}
