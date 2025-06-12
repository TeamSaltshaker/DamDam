import SnapKit
import UIKit

final class URLValidationStackView: UIStackView {
    let statusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .none
        return imageView
    }()

    let statusLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black500
        label.font = .pretendard(size: 12, weight: .regular)
        label.text = " "
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

extension URLValidationStackView {
    func setHiddenAnimated(_ hidden: Bool, duration: TimeInterval = 0.25) {
        if hidden {
            UIView.animate(withDuration: duration) {
                self.alpha = 0
                self.isHidden = true
            }
        } else {
            self.isHidden = false
            self.alpha = 0
            UIView.animate(withDuration: duration) {
                self.alpha = 1
                self.superview?.layoutIfNeeded()
            }
        }
    }
}
