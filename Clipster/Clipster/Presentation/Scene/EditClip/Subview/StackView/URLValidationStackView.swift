import SnapKit
import UIKit

final class URLValidationStackView: UIStackView {
    private let statusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark.circle.fill")
        imageView.tintColor = .green
        return imageView
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 13, weight: .light)
        label.text = "올바른 URL 입니다"
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension URLValidationStackView {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        spacing = 8
    }

    func setHierarchy() {
        [
            statusImageView,
            statusLabel
        ].forEach {
            addArrangedSubview($0)
        }
    }

    func setConstraints() {
        statusImageView.snp.makeConstraints { make in
            make.size.equalTo(20)
        }
    }
}
