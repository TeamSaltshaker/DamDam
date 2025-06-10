import UIKit

final class BackButton: UIButton {
    convenience init(_ title: String) {
        self.init(frame: .zero)
        configure()
        var config = configuration
        config?.title = title
        configuration = config
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

private extension BackButton {
    func configure() {
        setAttributes()
    }

    func setAttributes() {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "chevron.left")
        config.imagePadding = 8
        config.baseForegroundColor = .label
        config.contentInsets = .zero

        configuration = config

        titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
    }
}
