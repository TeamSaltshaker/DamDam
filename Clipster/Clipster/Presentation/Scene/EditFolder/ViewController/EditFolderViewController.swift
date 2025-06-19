import ReactorKit
import RxCocoa
import RxSwift
import SnapKit
import UIKit

final class EditFolderViewController: UIViewController, View {
    typealias Reactor = EditFolderReactor
    private let diContainer: DIContainer
    var disposeBag = DisposeBag()

    private let editFolderView = EditFolderView()

    var onAdditionComplete: ((Folder) -> Void)?

    init(reactor: Reactor, diContainer: DIContainer) {
        self.diContainer = diContainer
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = editFolderView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedBackground()
        editFolderView.folderTitleTextField.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    func bind(reactor: Reactor) {
        bindAction(to: reactor)
        bindState(from: reactor)
        bindRoute(from: reactor)
    }
}

private extension EditFolderViewController {
    func bindAction(to reactor: Reactor) {
        editFolderView.backButton.rx.tap
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)

        editFolderView.folderTitleTextField.rx.text.orEmpty
            .distinctUntilChanged()
            .map { .folderTitleChanged($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        editFolderView.folderTitleTextField.clearButton.rx.tap
            .map { .clearButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        editFolderView.selectedFolderView.folderViewTapGesture.rx.event
            .map { _ in .folderViewTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        editFolderView.saveButton.rx.tap
            .map { .saveButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }

    func bindState(from reactor: Reactor) {
        reactor.state
            .map { $0.navigationTitle }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind { [weak self] title in
                self?.editFolderView.commonNavigationView.setTitle(title)
            }
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.folderTitle }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: editFolderView.folderTitleTextField.rx.text)
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.isSavable }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: editFolderView.saveButton.rx.isEnabled)
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.parentFolderDisplay }
            .distinctUntilChanged { $0?.id == $1?.id }
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] display in
                self?.editFolderView.selectedFolderView.folderRowView.setDisplay(display)
            }
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.folder == nil }
            .take(1)
            .filter { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] _ in
                self?.editFolderView.folderTitleTextField.becomeFirstResponder()
            }
            .disposed(by: disposeBag)

        reactor.pulse(\.$phase)
            .compactMap { $0 }
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] phase in
                guard let self = self else { return }
                switch phase {
                case .idle:
                    break
                case .loading:
                    break
                case .success(let folder):
                    self.onAdditionComplete?(folder)
                    self.navigationController?.popViewController(animated: true)
                case .error(let message):
                    self.presentAlert(message: message)
                }
            }
            .disposed(by: disposeBag)
    }

    func bindRoute(from reactor: Reactor) {
        reactor.pulse(\.$route)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] route in
                guard let self else { return }
                switch route {
                case .showFolderSelector:
                    let currentState = reactor.currentState
                    let vm = self.diContainer.makeFolderSelectorReactorForFolder(parentFolder: currentState.parentFolder, folder: currentState.folder)
                    let vc = FolderSelectorViewController(reactor: vm, diContainer: diContainer)
                    vc.onSelectionComplete = { selected in
                        reactor.action.onNext(.selectFolder(selected: selected))
                    }

                    vc.modalPresentationStyle = .pageSheet
                    if let sheet = vc.sheetPresentationController {
                        sheet.detents = [.custom { $0.maximumDetentValue * 0.75 }]
                        sheet.prefersGrabberVisible = true
                    }

                    present(vc, animated: true)
                }
            }
            .disposed(by: disposeBag)
    }
}

private extension EditFolderViewController {
    func presentAlert(message: String) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        self.present(alert, animated: true)
    }
}

extension EditFolderViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= 100
    }
}

extension EditFolderViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}

extension EditFolderViewController: UISheetPresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        reactor?.action.onNext(.folderSelectorDismissed)
    }
}
