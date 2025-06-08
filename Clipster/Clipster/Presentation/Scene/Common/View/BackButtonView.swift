import RxCocoa
import UIKit

final class BackButtonView: UIView {
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .label
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        return label
    }()

    var tap: ControlEvent<Void> { backButton.rx.tap }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func setDisplay(_ title: String) {
        titleLabel.text = title
    }
}

private extension BackButtonView {
    func configure() {
        setHierarchy()
        setConstraints()
    }

    func setHierarchy() {
        [backButton, titleLabel]
            .forEach { addSubview($0) }
    }

    func setConstraints() {
        backButton.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.size.equalTo(32)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(backButton.snp.trailing)
            make.centerY.trailing.equalToSuperview()
        }
    }
}
