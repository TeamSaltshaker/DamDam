import RxSwift
import SnapKit
import UIKit

final class EditFolderView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "제목"
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()

    private let folderTitleTextField = EditFolderTextField()

    private let folderLabel: UILabel = {
        let label = UILabel()
        label.text = "저장폴더"
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()

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
        [titleLabel, folderTitleTextField, folderLabel]
            .forEach { addSubview($0) }
    }

    func setConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(24)
            make.directionalHorizontalEdges.equalToSuperview().inset(24)
        }

        folderTitleTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.directionalHorizontalEdges.equalToSuperview().inset(24)
            make.height.equalTo(48)
        }

        folderLabel.snp.makeConstraints { make in
            make.top.equalTo(folderTitleTextField.snp.bottom).offset(40)
            make.directionalHorizontalEdges.equalToSuperview().inset(24)
        }
    }
}
