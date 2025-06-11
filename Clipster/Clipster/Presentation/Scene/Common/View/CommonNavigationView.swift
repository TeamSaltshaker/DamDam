import UIKit

final class CommonNavigationView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendard(size: 22, weight: .bold)
        label.textColor = .black100
        return label
    }()

    private let leftStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 26
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }()

    private let rightStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 26
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func setTitle(_ title: String) {
        titleLabel.text = title
    }

    func setLeftItem(_ item: UIButton) {
        leftStackView.addArrangedSubview(item)
    }

    func setLeftItems(_ items: [UIButton]) {
        items.forEach {
            leftStackView.addArrangedSubview($0)
        }
    }

    func setRightItem(_ item: UIButton) {
        rightStackView.addArrangedSubview(item)
    }

    func setRightItems(_ items: [UIButton]) {
        items.forEach {
            rightStackView.addArrangedSubview($0)
        }
    }
}

private extension CommonNavigationView {
    func configure() {
        setHierarchy()
        setConstraints()
    }

    func setHierarchy() {
        [titleLabel, leftStackView, rightStackView]
            .forEach { addSubview($0) }
    }

    func setConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(12)
            make.centerX.equalToSuperview()
        }

        leftStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.centerY.equalToSuperview()
        }

        rightStackView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(24)
            make.centerY.equalToSuperview()
        }
    }
}
