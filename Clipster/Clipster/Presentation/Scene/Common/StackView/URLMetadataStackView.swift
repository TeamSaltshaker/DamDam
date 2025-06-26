import Kingfisher
import SnapKit
import UIKit

final class URLMetadataStackView: UIStackView {
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.image = .none
        imageView.backgroundColor = .black800
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
        label.font = .pretendard(size: 16, weight: .semiBold)
        label.numberOfLines = 2
        label.textColor = .black100
        label.text = " "
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setDisplay(display: URLMetadataDisplay) {
        titleLabel.text = display.title
        
        if let thumbnailURL = display.thumbnailImageURL {
            thumbnailImageView.kf.setImage(with: thumbnailURL)
        } else if let screenshotImageData = display.screenshotImageData,
                  let screenshotImage = UIImage(data: screenshotImageData) {
            thumbnailImageView.image = screenshotImage
        } else {
            thumbnailImageView.image = .none
        }
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
        backgroundColor = .white900
        layer.cornerRadius = 12
        clipsToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.black900.cgColor
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: layer.cornerRadius
        ).cgPath
        layoutMargins = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        isLayoutMarginsRelativeArrangement = true
    }

    func setHierarchy() {
        [thumbnailImageView, infoStackView].forEach {
            addArrangedSubview($0)
        }

        [titleLabel].forEach {
            infoStackView.addArrangedSubview($0)
        }
    }

    func setConstraints() {
        thumbnailImageView.snp.makeConstraints { make in
            make.width.equalTo(96)
            make.height.equalTo(72)
        }
    }
}

extension URLMetadataStackView {
    func setHiddenAnimated(_ hidden: Bool, duration: TimeInterval = 0.25) {
        if hidden {
            UIView.animate(withDuration: duration) {
                self.alpha = 0
                self.isHidden = true
            }
        } else {
            self.isHidden = false
            self.alpha = 0
            UIView.animate(withDuration: duration) {
                self.alpha = 1
                self.superview?.layoutIfNeeded()
            }
        }
    }
}
