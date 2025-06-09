import SnapKit
import UIKit

final class FolderRowView: UIView {
    private let folderImageBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        view.layer.cornerRadius = 8
        return view
    }()

    private let folderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "folder")
        imageView.tintColor = .systemBlue
        return imageView
    }()

    private let labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()

    private let countLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 12)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setDisplay(_ folder: FolderDisplay) {
        titleLabel.text = folder.title
        countLabel.text = folder.itemCount
    }
}

private extension FolderRowView {
    func configure() {
        setHierarchy()
        setConstraints()
    }

    func setHierarchy() {
        [folderImageBackgroundView, labelStackView]
            .forEach { addSubview($0) }

        folderImageBackgroundView.addSubview(folderImageView)

        [titleLabel, countLabel]
            .forEach { labelStackView.addArrangedSubview($0) }
    }

    func setConstraints() {
        folderImageBackgroundView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(48)
        }

        labelStackView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(0.5)
            make.leading.equalTo(folderImageBackgroundView.snp.trailing).offset(16)
            make.trailing.equalToSuperview()
        }

        folderImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(22)
        }
    }
}
