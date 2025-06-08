import UIKit

final class AddButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

private extension AddButton {
    func configure() {
        setAttributes()
    }

    func setAttributes() {
        setImage(UIImage(systemName: "plus"), for: .normal)
        tintColor = .label
    }
}
