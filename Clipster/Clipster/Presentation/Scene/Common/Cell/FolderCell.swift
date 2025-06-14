import SnapKit
import UIKit

final class FolderCell: UITableViewCell {
    private let folderRowView = FolderRowView()

    private let chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .chevronRight
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let inset = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        contentView.frame = contentView.frame.inset(by: inset)
    }

    func setDisplay(_ folder: FolderDisplay) {
        folderRowView.setDisplay(folder)
    }
}

private extension FolderCell {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        backgroundColor = .white800
        selectionStyle = .none

        contentView.backgroundColor = .white900
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
    }

    func setHierarchy() {
        [folderRowView, chevronImageView]
            .forEach { contentView.addSubview($0) }
    }

    func setConstraints() {
        folderRowView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }

        chevronImageView.snp.makeConstraints { make in
            make.leading.equalTo(folderRowView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }
    }
}
