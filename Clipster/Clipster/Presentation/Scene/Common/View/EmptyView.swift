import SnapKit
import UIKit

final class EmptyView: UIView {
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 13
        return stackView
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .empty
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.font = .pretendard(size: 16, weight: .medium)
        label.textColor = .black400
        label.numberOfLines = 2
        label.text = "현재 폴더 및 파일이 없습니다.\n상단 +버튼으로 추가해 보세요!"
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension EmptyView {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        backgroundColor = .white800
    }

    func setHierarchy() {
        [imageView, label].forEach {
            stackView.addArrangedSubview($0)
        }
        addSubview(stackView)
    }

    func setConstraints() {
        stackView.snp.makeConstraints { make in
            make.directionalHorizontalEdges.centerY.equalToSuperview()
            make.width.greaterThanOrEqualTo(200)
        }
    }
}
