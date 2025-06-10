import UIKit

final class SelectButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

private extension SelectButton {
    func configure() {
        setAttributes()
    }

    func setAttributes() {
        let normalFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
        let disabledFont = UIFont.systemFont(ofSize: 16, weight: .medium)

        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: normalFont,
            .foregroundColor: UIColor.systemBlue
        ]
        let disabledAttributes: [NSAttributedString.Key: Any] = [
            .font: disabledFont,
            .foregroundColor: UIColor.systemGray
        ]

        setAttributedTitle(NSAttributedString(string: "선택", attributes: normalAttributes), for: .normal)
        setAttributedTitle(NSAttributedString(string: "선택", attributes: disabledAttributes), for: .disabled)
    }
}
