import SnapKit
import Social
import UIKit
import UniformTypeIdentifiers

final class ShareViewController: UIViewController {
    private let appGroupID: String = {
        #if DEBUG
        return "group.com.saltshaker.clipster.debug"
        #else
        return "group.com.saltshaker.clipster"
        #endif
    }()

    private let urlScheme: String = {
        #if DEBUG
        return "damdamdebug://"
        #else
        return "damdam://"
        #endif
    }()

    private let shareView = ShareView()

    override func loadView() {
        view = shareView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        extractURL()
    }

    private func extractURL() {
        guard let extensionItems = extensionContext?.inputItems as? [NSExtensionItem] else {
            print("\(Self.self) ❌ No input items")
            close()
            return
        }

        for item in extensionItems {
            guard let attachments = item.attachments else { continue }

            for provider in attachments {
                for typeIdentifier in provider.registeredTypeIdentifiers {
                    print("\(Self.self) 📄 Trying type: \(typeIdentifier)")

                    provider.loadItem(forTypeIdentifier: typeIdentifier, options: nil) { [weak self] (item, error) in
                        guard let self else { return }

                        if let error = error {
                            print("\(Self.self) ❌ loadItem 에러: \(error.localizedDescription)")
                            return
                        }

                        if let url = extractURL(from: item) {
                            print("\(Self.self) ✅ 공유된 URL: \(url.absoluteString)")
                            if saveURLToUserDefaults(url) {
                                DispatchQueue.main.async {
                                    self.openMainApp()
                                }
                            }
                        } else {
                            print("\(Self.self) ⚠️ URL 변환 실패 - type: \(typeIdentifier)")
                        }
                    }
                }
            }
        }
    }

    private func extractURL(from item: NSSecureCoding?) -> URL? {
        if let url = item as? URL {
            return url
        } else if let string = item as? String {
            return extractFirstURL(from: string)
        } else if let data = item as? Data,
                  let string = String(data: data, encoding: .utf8) {
            return extractFirstURL(from: string)
        }
        return nil
    }

    private func extractFirstURL(from string: String) -> URL? {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector?.matches(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count))

        return matches?.first?.url
    }

    private func openMainApp() {
        if let url = URL(string: urlScheme) {
            if openURLScheme(url) {
                print("\(Self.self) ✅ URL Scheme open 성공")
            } else {
                print("\(Self.self) ❌ URL Scheme open 실패")
            }
        }
        close()
    }

    private func openURLScheme(_ url: URL) -> Bool {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                application.open(url, options: [:], completionHandler: nil)
                return true
            }
            responder = responder?.next
        }
        return false
    }

    private func saveURLToUserDefaults(_ url: URL) -> Bool {
        if let sharedDefaults = UserDefaults(suiteName: appGroupID) {
            sharedDefaults.set(url.absoluteString, forKey: "sharedURL")
            print("\(Self.self) ✅ UserDefaults에 URL 저장 완료: \(url.absoluteString)")
            return true
        } else {
            print("\(Self.self) ❌ UserDefaults App Group 접근 실패")
            return false
        }
    }

    private func close() {
        extensionContext?.completeRequest(returningItems: nil)
    }
}
