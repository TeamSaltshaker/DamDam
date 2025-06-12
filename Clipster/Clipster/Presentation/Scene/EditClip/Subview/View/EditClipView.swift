import SnapKit
import UIKit

final class EditClipView: UIView {
    let commonNavigationView = CommonNavigationView()
    let backButton = BackButton()
    let saveButton = SaveButton()

    let urlMetadataStackView: URLMetadataStackView = {
        let stackView = URLMetadataStackView(type: .edit)
        stackView.isHidden = true
        return stackView
    }()

    private let urlInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()

    let urlLabel: UILabel = {
        let label = UILabel()
        label.text = "URL"
        label.textColor = .black100
        label.font = .pretendard(size: 16, weight: .medium)
        return label
    }()

    let urlInputTextField: CommonTextField = {
        let textField = CommonTextField()
        textField.placeholder = "URL 입력"
        return textField
    }()

    let urlValidationStacKView: URLValidationStackView = {
        let stackView = URLValidationStackView()
        stackView.isHidden = true
        return stackView
    }()

    let memoLabel: UILabel = {
        let label = UILabel()
        label.text = "메모"
        label.font = .pretendard(size: 16, weight: .medium)
        label.textColor = .black100
        return label
    }()

    let memoTextView: UITextView = {
        let textView = UITextView()
        textView.font = .pretendard(size: 14, weight: .regular)
        textView.textColor = .black100
        textView.backgroundColor = .white900
        textView.contentInset = .init(top: 12, left: 12, bottom: 24, right: 12)
        textView.layer.cornerRadius = 12
        textView.clipsToBounds = true
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.black900.cgColor
        textView.layer.shadowPath = UIBezierPath(
            roundedRect: textView.bounds,
            cornerRadius: textView.layer.cornerRadius
        ).cgPath
        return textView
    }()

    let memoLimitLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black500
        label.font = .pretendard(size: 12, weight: .regular)
        return label
    }()

    let folderLabel: UILabel = {
        let label = UILabel()
        label.text = "저장폴더"
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()

    let addFolderButton: UIButton = {
        let button = UIButton()
        button.setImage(.plus, for: .normal)
        return button
    }()

    lazy var folderView: UIView = {
        let view = UIView()
        view.addGestureRecognizer(folderViewTapGesture)
        view.isUserInteractionEnabled = true
        return view
    }()

    let folderRowView = FolderRowView()

    private let chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .label
        return imageView
    }()

    let folderViewTapGesture = UITapGestureRecognizer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension EditClipView {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        commonNavigationView.setLeftItem(backButton)
        commonNavigationView.setRightItem(saveButton)
    }

    func setHierarchy() {
        [
            urlLabel,
            urlInputTextField,
            urlValidationStacKView
        ].forEach {
            urlInfoStackView.addArrangedSubview($0)
        }

        [
            folderRowView,
            chevronImageView
        ].forEach {
            folderView.addSubview($0)
        }

        [
            commonNavigationView,
            urlMetadataStackView,
            urlInfoStackView,
            memoLabel,
            memoTextView,
            memoLimitLabel,
            folderLabel,
            addFolderButton,
            folderView
        ].forEach {
            addSubview($0)
        }
    }

    func setConstraints() {
        commonNavigationView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.directionalHorizontalEdges.equalToSuperview()
        }

        urlMetadataStackView.snp.makeConstraints { make in
            make.top.equalTo(commonNavigationView.snp.bottom).offset(24)
            make.directionalHorizontalEdges.equalToSuperview().inset(24)
        }

        urlInfoStackView.snp.makeConstraints { make in
            make.top.equalTo(urlMetadataStackView.snp.bottom).offset(32)
            make.directionalHorizontalEdges.equalToSuperview().inset(24)
        }

        urlInputTextField.snp.makeConstraints { make in
            make.height.equalTo(48)
        }

        memoLabel.snp.makeConstraints { make in
            make.top.equalTo(urlInfoStackView.snp.bottom).offset(32)
            make.directionalHorizontalEdges.equalToSuperview().inset(24)
        }

        memoTextView.snp.makeConstraints { make in
            make.top.equalTo(memoLabel.snp.bottom).offset(8)
            make.directionalHorizontalEdges.equalToSuperview().inset(24)
            make.height.equalTo(96)
        }

        memoLimitLabel.snp.makeConstraints { make in
            make.right.bottom.equalTo(memoTextView).inset(12)
        }

        folderLabel.snp.makeConstraints { make in
            make.top.equalTo(memoTextView.snp.bottom).offset(40)
            make.leading.equalToSuperview().inset(28)
        }

        addFolderButton.snp.makeConstraints { make in
            make.top.equalTo(memoTextView.snp.bottom).offset(40)
            make.trailing.equalToSuperview().inset(28)
        }

        folderView.snp.makeConstraints { make in
            make.top.equalTo(folderLabel.snp.bottom).offset(12)
            make.directionalHorizontalEdges.equalToSuperview().inset(28)
            make.height.equalTo(72)
        }

        folderRowView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(12)
            make.leading.equalToSuperview().offset(20)
        }

        chevronImageView.snp.makeConstraints { make in
            make.leading.equalTo(folderRowView.snp.trailing).inset(16)
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }
    }
}
