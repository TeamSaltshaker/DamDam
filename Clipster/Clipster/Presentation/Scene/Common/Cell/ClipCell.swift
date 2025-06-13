import Kingfisher
import SnapKit
import UIKit

final class ClipCell: UITableViewCell {
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
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white900.cgColor
        view.isHidden = true
        return view
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

    func setDisplay(_ display: ClipDisplay) {
        thumbnailImageView.kf.setImage(with: display.urlMetadata.thumbnailImageURL)
        titleLabel.text = display.urlMetadata.title
        memoLabel.text = display.memo
        visitIndicatorView.isHidden = display.isVisited
    }
}

private extension ClipCell {
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
        [
            thumbnailImageView,
            stackView,
            chevronImageView,
            visitIndicatorView
        ].forEach { contentView.addSubview($0) }
    }

    func setConstraints() {
        thumbnailImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.verticalEdges.equalToSuperview().inset(12)
            make.width.equalTo(64)
        }

        stackView.snp.makeConstraints { make in
            make.leading.equalTo(thumbnailImageView.snp.trailing).offset(16)
            make.trailing.equalTo(chevronImageView.snp.leading).offset(-16)
            make.centerY.equalToSuperview()
        }

        chevronImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }

        visitIndicatorView.snp.makeConstraints { make in
            make.leading.equalTo(thumbnailImageView.snp.leading).inset(6)
            make.top.equalTo(thumbnailImageView.snp.top).inset(6)
            make.size.equalTo(8)
        }
    }
}
