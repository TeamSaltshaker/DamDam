import UIKit

final class EditFolderTextField: UITextField {
    let textPadding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 32)

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
        clearButtonMode = .whileEditing
        placeholder = "폴더 이름"
        layer.cornerRadius = 10
        backgroundColor = .secondarySystemBackground
    }
}
