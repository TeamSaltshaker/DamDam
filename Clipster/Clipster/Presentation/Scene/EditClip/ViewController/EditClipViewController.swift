import ReactorKit
import RxCocoa
import UIKit

final class EditClipViewController: UIViewController {
    typealias Reactor = EditClipReactor
    private let diContainer: DIContainer
    var disposeBag = DisposeBag()

    private let editClipView = EditClipView()

    init(reactor: EditClipReactor, diContainer: DIContainer) {
        self.diContainer = diContainer
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = editClipView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedBackground()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
}

extension EditClipViewController: View {
    func bind(reactor: EditClipReactor) {
        bindUI(to: reactor)
        bindState(from: reactor)
    }

    private func bindUI(to reactor: EditClipReactor) {
        editClipView.urlView.urlTextField
            .rx
            .text
            .orEmpty
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .map { Reactor.Action.editURLTextField($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        editClipView.urlView.urlTextField
            .rx
            .text
            .orEmpty
            .distinctUntilChanged()
            .skip(1)
            .map { _ in Reactor.Action.editingURLTextField }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        editClipView.memoView.memoTextView
            .rx
            .text
            .orEmpty
            .distinctUntilChanged()
            .map { Reactor.Action.editMemo($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        editClipView.memoView.memoTextView
            .rx
            .text
            .orEmpty
            .distinctUntilChanged()
            .map { String($0.prefix(100)) }
            .asDriver(onErrorJustReturn: "")
            .drive(editClipView.memoView.memoTextView.rx.text)
            .disposed(by: disposeBag)

        editClipView.selectedFolderView.addButton
            .rx
            .tap
            .subscribe { [weak self] _ in
                guard let self else { return }
                let editFolderReactor = diContainer.makeEditFolderReactor(parentFolder: reactor.currentState.currentFolder, folder: nil)
                let vc = EditFolderViewController(
                    reactor: editFolderReactor,
                    diContainer: diContainer
                )

                vc.onAdditionComplete = { [weak reactor] in
                    reactor?.action.onNext(.editFolder($0))
                }

                navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)

        editClipView.backButton
            .rx
            .tap
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)

        editClipView.selectedFolderView.folderViewTapGesture
            .rx
            .event
            .map { _ in Reactor.Action.tapFolderView }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        editClipView.saveButton
            .rx
            .tap
            .map { _ in Reactor.Action.saveClip }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }

    private func bindState(from reactor: EditClipReactor) {
        reactor.state
            .compactMap(\.clip)
            .take(1)
            .map { _ in Reactor.Action.fetchFolder }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.type == .shareExtension }
            .filter { $0 }
            .take(1)
            .map { _ in Reactor.Action.fetchTopLevelFolder }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state
            .map(\.urlString)
            .take(1)
            .asDriver(onErrorJustReturn: "")
            .drive(editClipView.urlView.urlTextField.rx.text)
            .disposed(by: disposeBag)

        reactor.state
            .map(\.memoText)
            .take(1)
            .asDriver(onErrorJustReturn: "")
            .drive(editClipView.memoView.memoTextView.rx.text)
            .disposed(by: disposeBag)

        reactor.state
            .map(\.navigationTitle)
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] in
                self?.editClipView.commonNavigationView.setTitle($0)
            }
            .disposed(by: disposeBag)

        reactor.state
            .map(\.urlTextFieldBorderColor)
            .map { UIColor(resource: $0).cgColor }
            .asDriver(onErrorDriveWith: .empty())
            .drive(editClipView.urlView.urlTextField.layer.rx.borderColor)
            .disposed(by: disposeBag)

        reactor.state
            .map(\.isHiddenURLMetadataStackView)
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] isHidden in
                self?.editClipView.urlMetadataStackView.setHiddenAnimated(isHidden)
            }
            .disposed(by: disposeBag)

        reactor.state
            .map(\.isHiddenURLValidationStackView)
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] isHidden in
                self?.editClipView.urlValidationStacKView.setHiddenAnimated(isHidden)
            }
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.currentFolder == nil }
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
            .drive(editClipView.selectedFolderView.folderView.rx.isHidden)
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.currentFolder != nil }
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
            .drive(editClipView.selectedFolderView.emptyView.rx.isHidden)
            .disposed(by: disposeBag)

        reactor.state
            .map(\.isLoading)
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] isLoading in
                if isLoading {
                    self?.editClipView.urlValidationStacKView.activityIndicatorView.startAnimating()
                } else {
                    self?.editClipView.urlValidationStacKView.activityIndicatorView.stopAnimating()
                }
            }
            .disposed(by: disposeBag)

        reactor.state
            .map(\.isSuccessedEditClip)
            .filter { $0 }
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)

        reactor.state
            .map { ($0.isTappedFolderView, $0.currentFolder) }
            .filter { $0 && $1 != nil }
            .map { $1 }
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] currentFolder in
                guard let self else { return }
                let reactor = diContainer.makeFolderSelectorReactorForClip(parentFolder: currentFolder)
                let vc = FolderSelectorViewController(reactor: reactor, diContainer: diContainer)
                vc.onSelectionComplete = { [weak self] in
                    self?.reactor?.action.onNext(.editFolder($0))
                }
                vc.modalPresentationStyle = .pageSheet
                if let sheet = vc.sheetPresentationController {
                    sheet.detents = [.custom { context in context.maximumDetentValue * 0.75 }]
                    sheet.prefersGrabberVisible = true
                }
                present(vc, animated: true)
                self.reactor?.action.onNext(.disappearFolderSelectorView)
            }
            .disposed(by: disposeBag)

        reactor.state
            .compactMap(\.currentFolder)
            .distinctUntilChanged { $0.id == $1.id }
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] in
                self?.editClipView.selectedFolderView.folderRowView.setDisplay(
                    FolderDisplayMapper.map($0)
                )
            }
            .disposed(by: disposeBag)

        reactor.state
            .map(\.memoLimit)
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "0 / 100")
            .drive(editClipView.memoView.memoLimitLabel.rx.text)
            .disposed(by: disposeBag)

        reactor.state
            .map { state in
                if let imageName = state.urlValidationImageName {
                    return UIImage(named: imageName)
                } else {
                    return .none
                }
            }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: .none)
            .drive(editClipView.urlValidationStacKView.statusImageView.rx.image)
            .disposed(by: disposeBag)

        reactor.state
            .map(\.urlValidationLabelText)
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
            .drive(editClipView.urlValidationStacKView.statusLabel.rx.text)
            .disposed(by: disposeBag)

        reactor.state
            .map(\.urlMetadataDisplay)
            .compactMap { $0 }
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] urlMetadataDisplay in
                self?.editClipView.urlMetadataStackView.setDisplay(model: urlMetadataDisplay)
            }
            .disposed(by: disposeBag)

        Observable.combineLatest(
            reactor.state.map(\.clip),
            reactor.state.map(\.memoText),
            reactor.state.map(\.isURLValid),
            reactor.state.map(\.currentFolder),
            reactor.state.map(\.isLoading),
            reactor.state.map(\.urlString)
        )
        .map { clip, memoText, isURLValid, currentFolder, isLoading, urlText in
            guard !isLoading else { return false }
            guard isURLValid else { return false }
            if let clip = clip {
                return clip.memo != memoText || currentFolder?.id != clip.folderID || clip.urlMetadata.url.absoluteString != urlText
            } else {
                return currentFolder != nil
            }
        }
        .distinctUntilChanged()
        .asDriver(onErrorDriveWith: .empty())
        .drive(editClipView.saveButton.rx.isEnabled)
        .disposed(by: disposeBag)
    }
}

extension EditClipViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
