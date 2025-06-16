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

    private let folderTitleContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black900.cgColor
        view.backgroundColor = .white900
        return view
    }()

    let folderTitleTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .black100
        textField.font = .pretendard(size: 14, weight: .regular)
        textField.attributedPlaceholder = NSAttributedString(
            string: "제목을 입력해 주세요.",
            attributes: [
                .foregroundColor: UIColor.black800,
                .font: UIFont.pretendard(size: 14, weight: .regular)
            ]
        )
        return textField
    }()

    let folderTitleLimitLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black500
        label.font = .pretendard(size: 12, weight: .regular)
        label.textAlignment = .right
        return label
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
        [commonNavigationView, titleLabel, folderTitleContainerView, folderLabel, folderView]
            .forEach { addSubview($0) }

        [folderTitleTextField, folderTitleLimitLabel]
            .forEach { folderTitleContainerView.addSubview($0) }

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
            make.directionalHorizontalEdges.equalToSuperview().inset(28)
        }

        folderTitleContainerView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.directionalHorizontalEdges.equalToSuperview().inset(24)
            make.height.equalTo(48)
        }

        folderTitleTextField.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }

        folderTitleLimitLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }

        folderLabel.snp.makeConstraints { make in
            make.top.equalTo(folderTitleContainerView.snp.bottom).offset(52)
            make.directionalHorizontalEdges.equalToSuperview().inset(28)
        }

        folderView.snp.makeConstraints { make in
            make.top.equalTo(folderLabel.snp.bottom).offset(24)
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
