import Social
import UIKit
import UniformTypeIdentifiers

final class ShareViewController: SLComposeViewController {
    private let appGroupID: String = {
        #if DEBUG
        return "group.com.saltshaker.clipster.debug"
        #else
        return "group.com.saltshaker.clipster"
        #endif
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        extractURL()
    }

    private func extractURL() {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let attachments = extensionItem.attachments,
              let provider = attachments.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.url.identifier) })
        else {
            print("\(Self.self) ❌ Share Extension inputItem parsing 에러")
            close()
            return
        }

        provider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { [weak self] (item, error) in
            guard let self else {
                self?.close()
                return
            }

            if let error = error {
                print("\(Self.self) ❌ URL 로딩 에러: \(error)")
                close()
                return
            }

            if let url = item as? URL {
                print("\(Self.self) ✅ 공유된 URL: \(url.absoluteString)")
                if saveURLToUserDefaults(url) {
                    DispatchQueue.main.async {
                        self.openMainApp()
                    }
                }
            } else {
                print("\(Self.self) ❌ URL 타입 변환 에러")
                close()
            }
        }
    }

    private func openMainApp() {
        if let url = URL(string: "clipster://") {
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
        self.extensionContext?.completeRequest(returningItems: nil)
    }
}
