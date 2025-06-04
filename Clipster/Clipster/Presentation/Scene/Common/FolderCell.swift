import SnapKit
import UIKit

final class FolderCell: UICollectionViewCell {
    private let folderImageContainerView: UIView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemBlue
        imageView.layer.cornerRadius = 12
        return imageView
    }()

    private let folderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "folder")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemIndigo
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .label
        return label
    }()

    private let itemCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .systemGray
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, itemCountLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()

    private let chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setDisplay(_ display: FolderCellDisplay) {
        titleLabel.text = display.title
        itemCountLabel.text = "\(display.itemCount) items"
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
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: layer.cornerRadius
        ).cgPath
    }

    func setHierarchy() {
        [
            folderImageContainerView,
            stackView,
            chevronImageView
        ].forEach { contentView.addSubview($0) }

        folderImageContainerView.addSubview(folderImageView)
    }

    func setConstraints() {
        folderImageContainerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.verticalEdges.equalToSuperview().inset(12)
            make.width.equalTo(folderImageContainerView.snp.height)
        }

        folderImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }

        stackView.snp.makeConstraints { make in
            make.leading.equalTo(folderImageContainerView.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }

        chevronImageView.snp.makeConstraints { make in
            make.leading.equalTo(stackView.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(16)
        }
    }
}
