import SnapKit
import UIKit
import WebKit

final class DDWebView: UIView {
    let commonNavigationView = CommonNavigationView()
    let backButton = BackButton()

    private var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.trackTintColor = .clear
        progressView.progressTintColor = .systemBlue
        return progressView
    }()

    lazy var webView: WKWebView = {
        let webViewConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webViewConfiguration)
        webView.allowsBackForwardNavigationGestures = true
        return webView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setProgress(progress: Double, animated: Bool = true) {
        progressView.alpha = 1.0
        progressView.setProgress(Float(progress), animated: animated)

        if progress >= 1.0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                UIView.animate(withDuration: 0.3) { [weak self] in
                    self?.progressView.alpha = 0.0
                } completion: { [weak self] _ in
                    self?.progressView.setProgress(0.0, animated: false)
                }
            }
        }
    }
}

private extension DDWebView {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        backgroundColor = .background
        commonNavigationView.setLeftItem(backButton)
    }

    func setHierarchy() {
        [
            commonNavigationView,
            progressView,
            webView
        ].forEach {
            addSubview($0)
        }
    }

    func setConstraints() {
        commonNavigationView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.directionalHorizontalEdges.equalToSuperview()
        }

        progressView.snp.makeConstraints { make in
            make.top.equalTo(commonNavigationView.snp.bottom)
            make.directionalHorizontalEdges.equalToSuperview()
            make.height.equalTo(2)
        }

        webView.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom)
            make.directionalHorizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
