import Kingfisher
import SnapKit
import UIKit

final class ClipListCell: UICollectionViewListCell {
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendard(size: 16, weight: .semiBold)
        label.textColor = .black100
        return label
    }()

    private let memoLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendard(size: 12, weight: .regular)
        label.textColor = .black500
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, memoLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fillProportionally
        return stackView
    }()

    private let chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .chevronRight
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let visitIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .blue400
        view.layer.cornerRadius = 4
        view.layer.borderWidth = 1.5
        view.layer.borderColor = UIColor.white900.cgColor
        view.isHidden = true
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
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

    func setDisplay(_ display: ClipDisplay) {
        thumbnailImageView.kf.setImage(with: display.urlMetadata.thumbnailImageURL)
        titleLabel.text = display.urlMetadata.title
        memoLabel.text = display.memo
        visitIndicatorView.isHidden = display.isVisited
    }
}

private extension ClipListCell {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        var background = UIBackgroundConfiguration.clear()
        background.backgroundColor = .white900
        background.cornerRadius = 12
        background.backgroundInsets = .init(top: 0, leading: 24, bottom: 0, trailing: 0)
        self.backgroundConfiguration = background
    }

    func setHierarchy() {
        [
            thumbnailImageView,
            stackView,
            chevronImageView,
            visitIndicatorView
        ].forEach { contentView.addSubview($0) }
    }

    func setConstraints() {
        thumbnailImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(44)
            make.width.equalTo(64)
            make.height.equalTo(48)
            make.centerY.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.leading.equalTo(thumbnailImageView.snp.trailing).offset(16)
            make.verticalEdges.equalToSuperview().inset(12.95)
        }

        chevronImageView.snp.makeConstraints { make in
            make.leading.equalTo(stackView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().inset(20)
            make.size.equalTo(24)
            make.centerY.equalToSuperview()
        }

        visitIndicatorView.snp.makeConstraints { make in
            make.leading.equalTo(thumbnailImageView.snp.leading).inset(6)
            make.top.equalTo(thumbnailImageView.snp.top).inset(6)
            make.size.equalTo(8)
        }
    }
}
