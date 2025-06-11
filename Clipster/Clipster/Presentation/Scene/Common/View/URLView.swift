import SnapKit
import UIKit

final class URLView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "URL"
        label.font = .pretendard(size: 16, weight: .medium)
        label.textColor = .black100
        return label
    }()

    let urlTextField: CommonTextField = {
        let textField = CommonTextField()
        textField.attributedPlaceholder = NSAttributedString(
            string: "URL을 입력해 주세요.",
            attributes: [
                .foregroundColor: UIColor.black800,
                .font: UIFont.pretendard(size: 14, weight: .regular)
            ]
        )
        return textField
    }()

    let statusImageView = UIImageView()

    let statusLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black500
        label.font = .pretendard(size: 12, weight: .regular)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

private extension URLView {
    func configure() {
        setHierarchy()
        setConstraints()
    }

    func setHierarchy() {
        [titleLabel, urlTextField, statusImageView, statusLabel]
            .forEach { addSubview($0) }
    }

    func setConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.directionalHorizontalEdges.equalToSuperview().inset(24)
        }

        urlTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.directionalHorizontalEdges.equalToSuperview().inset(24)
            make.height.equalTo(48)
        }

        statusImageView.snp.makeConstraints { make in
            make.top.equalTo(urlTextField.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(36)
            make.bottom.equalToSuperview().inset(16)
            make.size.equalTo(19)
        }

        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(urlTextField.snp.bottom).offset(8)
            make.leading.equalTo(statusImageView.snp.trailing).offset(4)
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(16)
        }
    }
}
