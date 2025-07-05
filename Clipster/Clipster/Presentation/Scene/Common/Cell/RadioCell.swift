import SnapKit
import UIKit

final class RadioCell: UITableViewCell {
    private let radioImageView: UIImageView = {
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

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setDisplay(text: String, isSelected: Bool) {
        titleLabel.text = text
        radioImageView.image = isSelected ? .radioSelected : .radioUnselected
    }
}

private extension RadioCell {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        contentView.backgroundColor = .white900
    }

    func setHierarchy() {
        [
            radioImageView,
            titleLabel
        ].forEach { contentView.addSubview($0) }
    }

    func setConstraints() {
        radioImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.size.equalTo(48)
            make.centerY.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(radioImageView.snp.trailing).offset(4)
            make.centerY.equalToSuperview()
        }
    }
}
