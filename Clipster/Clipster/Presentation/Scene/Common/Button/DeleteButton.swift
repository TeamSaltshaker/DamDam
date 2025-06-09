import UIKit

final class DeleteButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

private extension DeleteButton {
    func configure() {
        setAttributes()
    }

    func setAttributes() {
        setImage(UIImage(systemName: "trash"), for: .normal)
        tintColor = .systemRed
    }
}
