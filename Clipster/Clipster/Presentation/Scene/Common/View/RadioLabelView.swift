import SnapKit
import UIKit

final class RadioLabelView: UIView {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .radioUnselected
        imageView.backgroundColor = .clear
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black100
        label.font = .pretendard(size: 16, weight: .regular)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setDisplay(title: String, isSelected: Bool) {
        titleLabel.text = title
        imageView.image = isSelected ? .radioSelected : .radioUnselected
    }
}

private extension RadioLabelView {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        backgroundColor = .clear
    }

    func setHierarchy() {
        [
            imageView,
            titleLabel
        ].forEach { addSubview($0) }
    }

    func setConstraints() {
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.size.equalTo(48)
            make.centerY.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(4)
            make.centerY.equalToSuperview()
        }
    }
}
