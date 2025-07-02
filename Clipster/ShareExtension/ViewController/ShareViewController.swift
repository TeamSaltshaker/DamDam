import ReactorKit
import RxCocoa
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

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.reactor = ShareDIContainer().makeShareReactor()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = shareView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedBackground()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
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

    private func bindUI(to reactor: ShareReactor) {
        shareView.urlTextField
            .rx
            .controlEvent(.editingChanged)
            .withLatestFrom(shareView.urlTextField.rx.text.orEmpty)
            .distinctUntilChanged()
            .map { Reactor.Action.editURLTextField($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        shareView.urlTextField
            .rx
            .controlEvent(.editingChanged)
            .withLatestFrom(shareView.urlTextField.rx.text.orEmpty)
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .map { Reactor.Action.validifyURL($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        shareView.urlTextField
            .rx
            .controlEvent(.editingChanged)
            .withLatestFrom(shareView.urlTextField.rx.text.orEmpty)
            .distinctUntilChanged()
            .map { _ in Reactor.Action.editingURLTextField }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        shareView.memoView.memoTextView
            .rx
            .text
            .orEmpty
            .distinctUntilChanged()
            .map { Reactor.Action.editMemo($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        shareView.memoView.memoTextView
            .rx
            .text
            .orEmpty
            .distinctUntilChanged()
            .map { String($0.prefix(100)) }
            .asDriver(onErrorJustReturn: "")
            .drive(shareView.memoView.memoTextView.rx.text)
            .disposed(by: disposeBag)

        shareView.cancelButton
            .rx
            .tap
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] _ in
                self?.close()
            }
            .disposed(by: disposeBag)

        shareView.selectedFolderView.folderViewTapGesture
            .rx
            .event
            .map { _ in Reactor.Action.tapFolderView }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        shareView.saveButton
            .rx
            .tap
            .map { _ in Reactor.Action.saveClip }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        shareView.urlTextField.clearButton
            .rx
            .tap
            .flatMap { _ in
                Observable.of(
                    Reactor.Action.editURLTextField(""),
                    Reactor.Action.validifyURL("")
                )
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }

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

        reactor.state
            .map(\.urlString)
            .filter { !$0.isEmpty }
            .take(1)
            .observe(on: MainScheduler.asyncInstance)
            .flatMap { urlString in
                Observable.of(
                    .editingURLTextField,
                    .editURLTextField(urlString),
                    .validifyURL(urlString)
                )
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state
            .map(\.urlString)
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "")
            .drive(shareView.urlTextField.rx.text)
            .disposed(by: disposeBag)

        reactor.state
            .map(\.urlTextFieldBorderColor)
            .map { UIColor(resource: $0).cgColor }
            .asDriver(onErrorDriveWith: .empty())
            .drive(shareView.urlTextField.layer.rx.borderColor)
            .disposed(by: disposeBag)

        reactor.state
            .map(\.isHiddenURLMetadataStackView)
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] isHidden in
                self?.shareView.urlMetadataStackView.setHiddenAnimated(isHidden)
            }
            .disposed(by: disposeBag)

        reactor.state
            .map(\.isHiddenURLValidationStackView)
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] isHidden in
                self?.shareView.urlValidationStacKView.setHiddenAnimated(isHidden)
            }
            .disposed(by: disposeBag)

        reactor.state
            .map(\.isLoading)
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] isLoading in
                if isLoading {
                    self?.shareView.urlValidationStacKView.activityIndicatorView.startAnimating()
                } else {
                    self?.shareView.urlValidationStacKView.activityIndicatorView.stopAnimating()
                }
            }
            .disposed(by: disposeBag)

        reactor.state
            .map(\.isSuccessedEditClip)
            .filter { $0 }
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] _ in
                self?.close()
            }
            .disposed(by: disposeBag)

        reactor.state
            .observe(on: MainScheduler.asyncInstance)
            .map { ($0.isTappedFolderView, $0.currentFolder) }
            .filter { $0.0 }
            .map { $0.1 }
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] currentFolder in
                guard let self else { return }

                let reactor = ShareDIContainer().makeFolderSelectorReactorForClip(parentFolder: currentFolder)
                let vc = FolderSelectorViewController(reactor: reactor)

                vc.modalPresentationStyle = .pageSheet
                if let sheet = vc.sheetPresentationController {
                    sheet.detents = [.custom { $0.maximumDetentValue * 0.75 }]
                    sheet.prefersGrabberVisible = true
                }
                self.present(vc, animated: true)

                vc.onSelectionComplete = { [weak self] in
                    self?.reactor?.action.onNext(.editFolder($0))
                }
                self.reactor?.action.onNext(.disappearFolderSelectorView)
            }
            .disposed(by: disposeBag)

        reactor.state
            .map(\.currentFolder)
            .distinctUntilChanged { $0?.id == $1?.id }
            .asDriver(onErrorDriveWith: .empty())
            .drive(with: self) { owner, folder in
                let display = folder.map(FolderDisplayMapper.map)
                owner.shareView.selectedFolderView.folderRowView.setDisplay(display)
            }
            .disposed(by: disposeBag)

        reactor.state
            .map(\.memoLimit)
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "0 / 100")
            .drive(shareView.memoView.memoLimitLabel.rx.text)
            .disposed(by: disposeBag)

        reactor.state
            .map {
                if let imageResource = $0.urlValidationImageResource {
                    return UIImage(resource: imageResource)
                } else {
                    return .none
                }
            }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: .none)
            .drive(shareView.urlValidationStacKView.statusImageView.rx.image)
            .disposed(by: disposeBag)

        reactor.state
            .map(\.urlValidationLabelText)
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
            .drive(shareView.urlValidationStacKView.statusLabel.rx.text)
            .disposed(by: disposeBag)

        reactor.state
            .map(\.urlMetadataDisplay)
            .compactMap { $0 }
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] urlMetadataDisplay in
                self?.shareView.urlMetadataStackView.setDisplay(display: urlMetadataDisplay)
            }
            .disposed(by: disposeBag)

        Observable.combineLatest(
            reactor.state.map(\.isURLValid),
            reactor.state.map(\.isLoading)
        )
        .map { isURLValid, isLoading in
            !isLoading && isURLValid
        }
        .distinctUntilChanged()
        .asDriver(onErrorDriveWith: .empty())
        .drive(shareView.saveButton.rx.isEnabled)
        .disposed(by: disposeBag)
    }
}

extension ShareViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
