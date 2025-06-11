import SnapKit
import UIKit

final class EditClipView: UIView {
    let commonNavigationView = CommonNavigationView()
    let backButton = BackButton()
    let saveButton = SaveButton()

    private let urlInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()

    let urlMetadataStackView: URLMetadataStackView = {
        let stackView = URLMetadataStackView(type: .edit)
        stackView.isHidden = true
        return stackView
    }()

    let urlInputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "URL 입력"
        textField.borderStyle = .roundedRect
        return textField
    }()

    let urlValidationStacKView: URLValidationStackView = {
        let stackView = URLValidationStackView()
        stackView.isHidden = true
        return stackView
    }()

    let memoTextView: UITextView = {
        let textView = UITextView()
        textView.layer.cornerRadius = 12
        textView.clipsToBounds = true
        textView.textContainerInset = .init(top: 16, left: 16, bottom: 16, right: 16)
        textView.font = .systemFont(ofSize: 16)
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray5.cgColor
        return textView
    }()

    let memoLimitLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .monospacedDigitSystemFont(ofSize: 12, weight: .medium)
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
            urlMetadataStackView,
            urlInputTextField,
            urlValidationStacKView
        ].forEach {
            urlInfoStackView.addArrangedSubview($0)
        }

        [
            commonNavigationView,
            folderRowView,
            chevronImageView
        ].forEach {
            folderView.addSubview($0)
        }

        [
            urlInfoStackView,
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

        urlInfoStackView.snp.makeConstraints { make in
            make.top.equalTo(commonNavigationView.snp.bottom).offset(20)
            make.directionalHorizontalEdges.equalToSuperview().inset(20)
        }

        memoTextView.snp.makeConstraints { make in
            make.top.equalTo(urlInfoStackView.snp.bottom).offset(20)
            make.directionalHorizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(120)
        }

        memoLimitLabel.snp.makeConstraints { make in
            make.top.equalTo(memoTextView.snp.bottom).offset(10)
            make.right.equalToSuperview().inset(25)
        }

        folderLabel.snp.makeConstraints { make in
            make.top.equalTo(memoLimitLabel.snp.bottom).offset(40)
            make.leading.equalToSuperview().inset(28)
        }

        addFolderButton.snp.makeConstraints { make in
            make.top.equalTo(memoLimitLabel.snp.bottom).offset(40)
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
