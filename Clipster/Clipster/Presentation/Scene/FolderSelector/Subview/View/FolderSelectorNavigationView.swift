import RxCocoa
import SnapKit
import UIKit

final class FolderSelectorNavigationView: UIView {
    private let backButton = BackButton("이전폴더")
    private let titleView = UIView()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        return label
    }()

    private let selectButton = SelectButton()

    var backButtonTap: ControlEvent<Void> { backButton.rx.tap }
    var selectButtonTap: ControlEvent<Void> { selectButton.rx.tap }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

private extension FolderSelectorNavigationView {
    func configure() {
        setHierarchy()
        setConstraints()
    }

    func setHierarchy() {
        [backButton, titleView, titleLabel, selectButton]
            .forEach { addSubview($0) }
    }

    func setConstraints() {
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.centerY.equalToSuperview()
        }
        backButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        titleView.snp.makeConstraints { make in
            make.leading.equalTo(backButton.snp.trailing).offset(8)
            make.trailing.equalTo(selectButton.snp.leading).offset(-8)
            make.top.bottom.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(titleView.snp.leading)
            make.trailing.lessThanOrEqualTo(titleView.snp.trailing)
            make.centerX.equalToSuperview().priority(.high)
            make.centerY.equalToSuperview()
        }

        selectButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(24)
            make.centerY.equalToSuperview()
        }
        selectButton.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
}
