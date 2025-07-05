import SnapKit
import UIKit

final class SavePathLayoutRadioImageView: UIView {
    private let radioLabelView = RadioLabelView()

    private let previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setDisplay(title: String, isSelected: Bool, previewImage: UIImage) {
        radioLabelView.setDisplay(title: title, isSelected: isSelected)
        previewImageView.image = previewImage
    }
}

private extension SavePathLayoutRadioImageView {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        backgroundColor = .clear
    }

    func setHierarchy() {
        [
            radioLabelView,
            previewImageView
        ].forEach { addSubview($0) }
    }

    func setConstraints() {
        radioLabelView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(36)
        }

        previewImageView.snp.makeConstraints { make in
            make.top.equalTo(radioLabelView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
        }
    }
}
