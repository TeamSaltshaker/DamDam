import ReactorKit
import UIKit
import WebKit

final class DDWebViewController: UIViewController, WKUIDelegate {
    typealias Reactor = DDWebReactor

    var showTabBar: (() -> Void)?
    var disposeBag = DisposeBag()
    private let ddWebView = DDWebView()

    init(reactor: DDWebReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }

    deinit {
        ddWebView.webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
        ddWebView.webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.title))
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
        reactor?.action.onNext(.viewDidLoad)
        ddWebView.webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        ddWebView.webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        showTabBar?()
    }
}

extension DDWebViewController: View {
    func bind(reactor: DDWebReactor) {
        bindUI(to: reactor)
        bindState(to: reactor)
    }

    private func bindUI(to reactor: DDWebReactor) {
        ddWebView.backButton
            .rx
            .tap
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }

    private func bindState(to reactor: DDWebReactor) {
        reactor.state
            .map(\.isViewDidLoad)
            .filter { $0 }
            .subscribe { [weak self] _ in
                let request = URLRequest(url: reactor.currentState.url)
                self?.ddWebView.webView.load(request)
            }
            .disposed(by: disposeBag)
    }
}

extension DDWebViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}

extension DDWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}

extension DDWebViewController {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            ddWebView.setProgress(progress: ddWebView.webView.estimatedProgress)
        } else if keyPath == "title" {
            if let newTitle = change?[.newKey] as? String {
                ddWebView.commonNavigationView.setTitle(newTitle)
            }
        }
    }
}
