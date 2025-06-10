import Social
import UIKit

final class ShareViewController: SLComposeViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        openMainApp()
    }

    private func openMainApp() {
        if let url = URL(string: "clipster://") {
            if openURL(url) {
                print("url scheme success")
            } else {
                print("url scheme failed")
            }
        }
        self.extensionContext?.completeRequest(returningItems: nil)
    }

    private func openURL(_ url: URL) -> Bool {
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
}
