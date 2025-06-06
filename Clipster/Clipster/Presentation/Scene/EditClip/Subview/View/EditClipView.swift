import SnapKit
import UIKit

final class EditClipView: UIView {
    let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("저장", for: .normal)
        button.setTitleColor(.tintColor, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.frame = .init(x: 0, y: 0, width: 44, height: 44)
        return button
    }()

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
        setHierarchy()
        setConstraints()
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
            urlInfoStackView,
            memoTextView,
            memoLimitLabel
        ].forEach {
            addSubview($0)
        }
    }

    func setConstraints() {
        urlInfoStackView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(20)
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
    }
}
