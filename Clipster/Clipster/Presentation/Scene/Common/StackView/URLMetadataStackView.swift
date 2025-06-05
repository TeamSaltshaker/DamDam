import Kingfisher
import SnapKit
import UIKit

final class URLMetadataStackView: UIStackView {
    enum URLMetadataType {
        case edit
        case detail
    }

    let type: URLMetadataType

    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        return imageView
    }()

    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        stackView.spacing = 8
        return stackView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 2
        label.textColor = .label
        return label
    }()

    private lazy var linkLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.numberOfLines = 2
        label.textColor = .link
        if case .edit = type { label.isHidden = true }
        return label
    }()

    init(type: URLMetadataType) {
        self.type = type
        super.init(frame: .zero)
        configure()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setDisplay(model: URLMetadataDisplay) {
        titleLabel.text = model.title
        linkLabel.text = model.url.absoluteString
        thumbnailImageView.kf.setImage(with: model.thumbnailImageURL)
    }
}

private extension URLMetadataStackView {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        axis = .horizontal
        spacing = 12
        distribution = .fillProportionally
        alignment = .top
    }

    func setHierarchy() {
        [thumbnailImageView, infoStackView].forEach {
            addArrangedSubview($0)
        }

        [titleLabel, linkLabel].forEach {
            infoStackView.addArrangedSubview($0)
        }
    }

    func setConstraints() {
        thumbnailImageView.snp.makeConstraints { make in
            make.width.equalTo(80)
            make.height.equalTo(thumbnailImageView.snp.width)
        }
    }
}
