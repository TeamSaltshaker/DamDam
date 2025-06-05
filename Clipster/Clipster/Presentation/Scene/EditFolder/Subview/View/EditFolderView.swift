import RxSwift
import SnapKit
import UIKit

final class EditFolderView: UIView {
    let backButton = EditFolderBackButton()
    let saveButton = EditFolderSaveButton()
    private let folderTitleTextField = EditFolderTextField()

    var folderTitleChanges: Observable<String> {
        folderTitleTextField.rx.text.orEmpty.asObservable()
    }

    var folderTitleBinder: Binder<String?> {
        folderTitleTextField.rx.text
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func setTextFieldInteraction(enabled: Bool) {
        folderTitleTextField.isUserInteractionEnabled = enabled
    }
}

private extension EditFolderView {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        backgroundColor = .systemBackground
    }

    func setHierarchy() {
        addSubview(folderTitleTextField)
    }

    func setConstraints() {
        folderTitleTextField.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(16)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
    }
}
