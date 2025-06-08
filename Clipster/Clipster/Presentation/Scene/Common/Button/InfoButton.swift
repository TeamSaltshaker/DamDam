import UIKit

final class InfoButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

private extension InfoButton {
    func configure() {
        setAttributes()
    }

    func setAttributes() {
        setImage(UIImage(systemName: "info.circle"), for: .normal)
        tintColor = .label
    }
}
