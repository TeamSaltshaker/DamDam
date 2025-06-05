import UIKit

final class EditFolderSaveButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

private extension EditFolderSaveButton {
    func configure() {
        setAttributes()
    }

    func setAttributes() {
        setTitle("저장", for: .normal)
        setTitleColor(.systemBlue, for: .normal)
    }
}
