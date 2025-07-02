import ReactorKit
import SnapKit
import Social
import UIKit
import UniformTypeIdentifiers

final class ShareViewController: UIViewController {
    typealias Reactor = ShareReactor

    var disposeBag = DisposeBag()

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

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.reactor = ShareReactor()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reactor?.action.onNext(.viewWillAppear)
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
                            reactor?.action.onNext(.extractedURL(url))
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

    private func close() {
        extensionContext?.completeRequest(returningItems: nil)
    }
}

extension ShareViewController: View {
    func bind(reactor: ShareReactor) {
        bindUI(to: reactor)
        bindState(from: reactor)
    }

    private func bindUI(to reactor: ShareReactor) {}

    private func bindState(from reactor: ShareReactor) {
        reactor.state
            .filter(\.isReadyToExtractURL)
            .take(1)
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] event in
                guard let self else { return }
                if case .next = event {
                    extractURL()
                }
            }
            .disposed(by: disposeBag)
    }
}
