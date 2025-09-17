import ReactorKit
import UIKit
import WebKit

final class DDWebViewController: UIViewController, WKUIDelegate {
    typealias Reactor = DDWebReactor

    var disposeBag = DisposeBag()
    private let ddWebView = DDWebView()

    init(reactor: DDWebReactor) {
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
        reactor?.action.onNext(.viewDidLoad)
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
