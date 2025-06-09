import UIKit

final class EditFolderTextField: UITextField {
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

extension EditFolderTextField {
    func configure() {
        setAttributes()
    }

    func setAttributes() {
        placeholder = "제목을 입력하세요."
        layer.borderWidth = 1
        layer.cornerRadius = 12
        layer.borderColor = UIColor.tertiaryLabel.cgColor
    }
}
