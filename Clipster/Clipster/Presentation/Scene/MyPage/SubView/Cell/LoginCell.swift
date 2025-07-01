import SnapKit
import UIKit

final class LoginCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 14
        imageView.layer.borderColor = UIColor.black900.cgColor
        imageView.layer.borderWidth = 1
        imageView.contentMode = .center
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendard(size: 14, weight: .semiBold)
        label.textColor = .black100
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel])
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }

    func setDisplay(_ login: LoginType) {
        imageView.image = login.icon
        imageView.backgroundColor = login.backgroundColor
        titleLabel.text = login.title
    }
}

private extension LoginCell {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        contentView.backgroundColor = .white900
        contentView.layer.cornerRadius = 24
        contentView.layer.borderColor = UIColor.black900.cgColor
        contentView.layer.borderWidth = 1
    }

    func setHierarchy() {
        [
            stackView
        ].forEach { contentView.addSubview($0) }
    }

    func setConstraints() {
        imageView.snp.makeConstraints { make in
            make.size.equalTo(28)
        }

        stackView.snp.makeConstraints { make in
            make.width.equalTo(138)
            make.center.equalToSuperview()
        }
    }
}
