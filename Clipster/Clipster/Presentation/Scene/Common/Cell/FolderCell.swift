import SnapKit
import UIKit

final class FolderCell: UITableViewCell {
    private let folderRowView = FolderRowView()

    private let chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setDisplay(_ display: FolderDisplay) {
        folderRowView.setDisplay(display)
    }
}

private extension FolderCell {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 16
    }

    func setHierarchy() {
        [
            folderRowView,
            chevronImageView
        ].forEach { contentView.addSubview($0) }
    }

    func setConstraints() {
        folderRowView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(12)
            make.leading.equalToSuperview().inset(20)
        }

        chevronImageView.snp.makeConstraints { make in
            make.leading.equalTo(folderRowView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }
    }
}
