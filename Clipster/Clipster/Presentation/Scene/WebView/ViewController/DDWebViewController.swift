import UIKit
import WebKit

final class DDWebViewController: UIViewController, WKUIDelegate {
    private let ddWebView = DDWebView()
    private let url: URL

    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = ddWebView
        ddWebView.webView.uiDelegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let request = URLRequest(url: url)
        ddWebView.webView.load(request)
    }
}

extension DDWebViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
