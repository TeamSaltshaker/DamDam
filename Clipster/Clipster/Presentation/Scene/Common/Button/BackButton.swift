import UIKit

final class BackButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func setDisplay(_ title: String) {
        var config = configuration
        config?.title = title
        configuration = config
    }
}

private extension BackButton {
    func configure() {
        setAttributes()
    }

    func setAttributes() {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "chevron.left")
        config.imagePadding = 12
        config.baseForegroundColor = .label
        config.contentInsets = .zero

        configuration = config

        titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
    }
}
