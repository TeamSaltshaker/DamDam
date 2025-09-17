import ReactorKit
import UIKit
import WebKit

final class DDWebViewController: UIViewController, WKUIDelegate {
    typealias Reactor = DDWebReactor

    var disposeBag = DisposeBag()
    private let ddWebView = DDWebView()
    private let url: URL

    init(reactor: DDWebReactor, url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
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

extension DDWebViewController: View {
    func bind(reactor: DDWebReactor) {
        bindUI(to: reactor)
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
}

extension DDWebViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
