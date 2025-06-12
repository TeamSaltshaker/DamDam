import RxSwift
import SnapKit
import UIKit

final class EditFolderView: UIView {
    let commonNavigationView = CommonNavigationView()
    let backButton = BackButton()
    let saveButton = SaveButton()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "제목"
        label.textColor = .black100
        label.font = .pretendard(size: 16, weight: .medium)
        return label
    }()

    private let folderTitleTextField: CommonTextField = {
        let textField = CommonTextField()
        textField.placeholder = "제목을 입력해 주세요."
        return textField
    }()

    let folderLabel: UILabel = {
        let label = UILabel()
        label.text = "저장폴더"
        label.textColor = .black100
        label.font = .pretendard(size: 16, weight: .medium)
        return label
    }()

    let folderView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        view.backgroundColor = .white900
        view.layer.cornerRadius = 12
        return view
    }()

    let folderRowView = FolderRowView()

    private let chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .chevronRight
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    var folderTitleChanges: Observable<String> {
        folderTitleTextField.rx.text.orEmpty.asObservable()
    }

    var folderTitleBinder: Binder<String?> {
        folderTitleTextField.rx.text
    }

    let folderViewTapGesture = UITapGestureRecognizer()

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
        setBindings()
    }

    func setAttributes() {
        backgroundColor = .white800

        commonNavigationView.setLeftItem(backButton)
        commonNavigationView.setRightItem(saveButton)
    }

    func setHierarchy() {
        [commonNavigationView, titleLabel, folderTitleTextField, folderLabel, folderView]
            .forEach { addSubview($0) }

        [folderRowView, chevronImageView]
            .forEach { folderView.addSubview($0) }
    }

    func setConstraints() {
        commonNavigationView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.directionalHorizontalEdges.equalToSuperview()
        }

        backButton.snp.makeConstraints { make in
            make.size.equalTo(48)
        }

        saveButton.snp.makeConstraints { make in
            make.size.equalTo(48)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(commonNavigationView.snp.bottom).offset(24)
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

        folderView.snp.makeConstraints { make in
            make.top.equalTo(folderLabel.snp.bottom).offset(12)
            make.directionalHorizontalEdges.equalToSuperview().inset(24)
            make.height.equalTo(72)
        }

        folderRowView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(12)
            make.leading.equalToSuperview().offset(20)
        }

        chevronImageView.snp.makeConstraints { make in
            make.leading.equalTo(folderRowView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }
    }

    func setBindings() {
        folderView.addGestureRecognizer(folderViewTapGesture)
    }
}
