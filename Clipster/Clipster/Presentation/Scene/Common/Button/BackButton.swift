import UIKit

final class BackButton: UIButton {
    convenience init(_ title: String) {
        self.init(frame: .zero)
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
        config.image = .chevronLeft
        config.imagePadding = 8
        config.contentInsets = .zero

        configuration = config

        titleLabel?.font = .pretendard(size: 14, weight: .medium)
    }
}
