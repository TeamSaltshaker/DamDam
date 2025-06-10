import Kingfisher
import SnapKit
import UIKit

final class ClipGridCell: UICollectionViewCell {
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        return imageView
    }()

    private let visitIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 6
        view.isHidden = true
        return view
    }()

    private let titleTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 14, weight: .medium)
        textView.textColor = .label
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.isSelectable = false
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        return textView
    }()

    private let memoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .systemGray
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        setHierarchy()
        setConstraints()
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
            make.horizontalEdges.equalToSuperview().inset(4)
            make.height.equalTo(44)
        }

        memoLabel.snp.makeConstraints { make in
            make.top.equalTo(titleTextView.snp.bottom)
            make.horizontalEdges.equalToSuperview().inset(4)
            make.height.equalTo(19)
        }

        visitIndicatorView.snp.makeConstraints { make in
            make.top.leading.equalTo(thumbnailImageView).inset(8)
            make.size.equalTo(12)
        }
    }
}
