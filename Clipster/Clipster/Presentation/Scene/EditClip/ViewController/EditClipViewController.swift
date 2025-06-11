import RxCocoa
import RxSwift
import UIKit

final class EditClipViewController: UIViewController {
    private let viewModel: EditClipViewModel
    private let diContainer: DIContainer
    private let disposeBag = DisposeBag()

    private let editClipView = EditClipView()

    init(viewModel: EditClipViewModel, diContainer: DIContainer) {
        self.viewModel = viewModel
        self.diContainer = diContainer
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = editClipView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        hideKeyboardWhenTappedBackground()
    }
}

private extension EditClipViewController {
    func configure() {
        setAttributes()
        setBindings()
    }

    func setAttributes() {
        view.backgroundColor = .systemBackground
    }

    func setBindings() {
        viewModel.state
            .map(\.urlInputText)
            .take(1)
            .asDriver(onErrorJustReturn: "")
            .drive(editClipView.urlInputTextField.rx.text)
            .disposed(by: disposeBag)

        viewModel.state
            .map(\.memoText)
            .take(1)
            .asDriver(onErrorJustReturn: "")
            .drive(editClipView.memoTextView.rx.text)
            .disposed(by: disposeBag)

        editClipView.urlInputTextField
            .rx
            .text
            .orEmpty
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] in
                self?.viewModel.action.accept(.editURLInputTextField($0))
            }
            .disposed(by: disposeBag)

        viewModel.state
            .map(\.isHiddenURLMetadataStackView)
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] isHidden in
                self?.editClipView.urlMetadataStackView.setHiddenAnimated(isHidden)
            }
            .disposed(by: disposeBag)

        viewModel.state
            .map(\.isHiddenURLValidationStackView)
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] isHidden in
                self?.editClipView.urlValidationStacKView.setHiddenAnimated(isHidden)
            }
            .disposed(by: disposeBag)

        editClipView.memoTextView
            .rx
            .text
            .orEmpty
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] in
                self?.viewModel.action.accept(.editMomo($0))
            }
            .disposed(by: disposeBag)

        editClipView.memoTextView
            .rx
            .text
            .orEmpty
            .distinctUntilChanged()
            .map { String($0.prefix(100)) }
            .asDriver(onErrorJustReturn: "")
            .drive(editClipView.memoTextView.rx.text)
            .disposed(by: disposeBag)

        viewModel.state
            .map(\.memoLimit)
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "0/100")
            .drive(editClipView.memoLimitLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.state
            .map(\.urlValidationImageName)
            .map { UIImage(systemName: $0) }
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
            .drive(editClipView.urlValidationStacKView.statusImageView.rx.image)
            .disposed(by: disposeBag)

        viewModel.state
            .map(\.urlValidationLabelText)
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
            .drive(editClipView.urlValidationStacKView.statusLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.state
            .map(\.urlMetadata)
            .compactMap { $0 }
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] urlMetadataDisplay in
                self?.editClipView.urlMetadataStackView.setDisplay(model: urlMetadataDisplay)
            }
            .disposed(by: disposeBag)

        Observable.combineLatest(
            viewModel.state.map(\.memoText),
            viewModel.state.map(\.isURLValid),
        )
        .map { memoText, isURLValid in
            !memoText.isEmpty && isURLValid
        }
        .distinctUntilChanged()
        .asDriver(onErrorDriveWith: .empty())
        .drive(editClipView.saveButton.rx.isEnabled)
        .disposed(by: disposeBag)

        editClipView.addFolderButton
            .rx
            .tap
            .subscribe { [weak self] _ in
                guard let self else { return }
                let vm = diContainer.makeEditFolderViewModel(mode: .add(parentFolder: viewModel.state.value.currentFolder))
                let vc = EditFolderViewController(
                    viewModel: vm,
                    diContainer: diContainer
                )
                navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)

        editClipView.backButton
            .rx
            .tap
            .subscribe { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
}
