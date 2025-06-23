import ReactorKit
import RxCocoa
import UIKit

final class EditClipViewController: UIViewController {
    typealias Reactor = EditClipReactor

    var disposeBag = DisposeBag()
    private let editClipView = EditClipView()
    private weak var coordinator: HomeCoordinator?

    init(reactor: EditClipReactor, coordinator: HomeCoordinator) {
        self.coordinator = coordinator
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
            .skip(1)
            .map { Reactor.Action.editURLTextField($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        editClipView.urlView.urlTextField
            .rx
            .text
            .orEmpty
            .skip(1)
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .map { Reactor.Action.validifyURL($0) }
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
                let parentFolder = reactor.currentState.currentFolder
                coordinator?.showAddFolder(parentFolder: parentFolder) { [weak reactor] in
                    reactor?.action.onNext(.editFolder($0))
                }
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

        editClipView.urlView.urlTextField.clearButton
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

    private func bindState(from reactor: EditClipReactor) {
        reactor.state
            .map { $0.type }
            .filter { $0 == .create }
            .take(1)
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] _ in
                self?.editClipView.urlView.urlTextField.becomeFirstResponder()
            }
            .disposed(by: disposeBag)

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
            .map(\.memoText)
            .take(1)
            .asDriver(onErrorJustReturn: "")
            .drive(editClipView.memoView.memoTextView.rx.text)
            .disposed(by: disposeBag)

        reactor.state
            .map(\.urlString)
            .take(1)
            .filter { !$0.isEmpty }
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
            .drive(editClipView.urlView.urlTextField.rx.text)
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
                coordinator?.showFolderSelectorForClip(parentFolder: currentFolder) { [weak reactor] in
                    reactor?.action.onNext(.editFolder($0))
                }
                reactor.action.onNext(.disappearFolderSelectorView)
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
            .map {
                if let imageResource = $0.urlValidationImageResource {
                    return UIImage(resource: imageResource)
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
                self?.editClipView.urlMetadataStackView.setDisplay(display: urlMetadataDisplay)
            }
            .disposed(by: disposeBag)

        Observable.combineLatest(
            reactor.state.map(\.isURLValid),
            reactor.state.map(\.currentFolder),
            reactor.state.map(\.isLoading)
        )
        .map { isURLValid, currentFolder, isLoading in
            !isLoading && isURLValid && currentFolder != nil
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
