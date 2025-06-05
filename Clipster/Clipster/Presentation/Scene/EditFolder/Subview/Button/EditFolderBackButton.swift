import SnapKit
import UIKit

final class EditFolderBackButton: UIView {
    private let backButton = UIButton()
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func setDisplay(_ title: String) {
        titleLabel.text = title
    }
}

private extension EditFolderBackButton {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        backButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        backButton.tintColor = .systemBlue

        titleLabel.font = .boldSystemFont(ofSize: 17)
        titleLabel.textColor = .label
    }

    func setHierarchy() {
        [backButton, titleLabel]
            .forEach { addSubview($0) }
    }

    func setConstraints() {
        backButton.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.height.equalTo(24)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(backButton.snp.trailing).offset(8)
            make.centerY.trailing.equalToSuperview()
        }
    }
}
