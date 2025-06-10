import UIKit

final class SelectButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

private extension SelectButton {
    func configure() {
        setAttributes()
    }

    func setAttributes() {
        setTitle("선택", for: .normal)
        setTitleColor(.systemBlue, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
    }
}
