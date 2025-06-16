import UIKit

final class CommonTextField: UITextField {
    let textPadding = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: textPadding)
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: textPadding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: textPadding)
    }
}

private extension CommonTextField {
    func configure() {
        setAttributes()
    }

    func setAttributes() {
        let commonFont = UIFont.pretendard(size: 14, weight: .regular)

        layer.borderWidth = 1
        layer.cornerRadius = 12
        layer.borderColor = UIColor.black900.cgColor
        backgroundColor = .white900
        font = commonFont
        textColor = .black100
        attributedPlaceholder = NSAttributedString(
            string: "URL을 입력해 주세요.",
            attributes: [
                .foregroundColor: UIColor.black800,
                .font: commonFont
            ]
        )
    }
}
