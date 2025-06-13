import Kingfisher
import SnapKit
import UIKit

final class ClipGridCell: UICollectionViewCell {
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .black800
        return imageView
    }()

    private let visitIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .blue400
        view.layer.cornerRadius = 6
        view.isHidden = true
        return view
    }()

    private let titleTextView: UITextView = {
        let textView = UITextView()
        textView.font = .init(name: "Pretendard-Medium", size: 14)
        textView.textColor = .black100
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.isSelectable = false
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.isUserInteractionEnabled = false
        return textView
    }()

    private let memoLabel: UILabel = {
        let label = UILabel()
        label.font = .init(name: "Pretendard-Regular", size: 12)
        label.textColor = .black300
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
    }

    func setDisplay(_ display: ClipDisplay) {
        thumbnailImageView.kf.setImage(with: display.urlMetadata.thumbnailImageURL)
        titleTextView.text = display.urlMetadata.title
        memoLabel.text = display.memo
        visitIndicatorView.isHidden = display.isVisited
    }
}

private extension ClipGridCell {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        contentView.backgroundColor = .white900
        layer.cornerRadius = 12
        clipsToBounds = true
    }

    func setHierarchy() {
        [
            thumbnailImageView,
            titleTextView,
            memoLabel,
            visitIndicatorView
        ].forEach { contentView.addSubview($0) }
    }

    func setConstraints() {
        thumbnailImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(thumbnailImageView.snp.width).multipliedBy(0.75)
        }

        titleTextView.snp.makeConstraints { make in
            make.top.equalTo(thumbnailImageView.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(8)
            make.height.equalTo(44)
        }

        memoLabel.snp.makeConstraints { make in
            make.top.equalTo(titleTextView.snp.bottom)
            make.horizontalEdges.equalToSuperview().inset(8)
            make.height.equalTo(17.94)
        }

        visitIndicatorView.snp.makeConstraints { make in
            make.top.leading.equalTo(thumbnailImageView).inset(8)
            make.size.equalTo(12)
        }
    }
}
