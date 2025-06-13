import SnapKit
import UIKit

final class MemoView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "메모"
        label.font = .pretendard(size: 16, weight: .medium)
        label.textColor = .black100
        return label
    }()

    private let memoContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black900.cgColor
        view.backgroundColor = .white900
        return view
    }()

    let memoTextView: UITextView = {
        let textView = UITextView()
        textView.font = .pretendard(size: 14, weight: .regular)
        return textView
    }()

    let memoLimitLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black500
        label.font = .pretendard(size: 12, weight: .regular)
        label.textAlignment = .right
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension MemoView {
    func configure() {
        setHierarchy()
        setConstraints()
    }

    func setHierarchy() {
        [titleLabel, memoContainerView]
            .forEach { addSubview($0) }

        [memoTextView, memoLimitLabel]
            .forEach { memoContainerView.addSubview($0) }
    }

    func setConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.directionalHorizontalEdges.equalToSuperview().inset(24)
        }

        memoContainerView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.directionalHorizontalEdges.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(16)
            make.height.equalTo(96)
        }

        memoTextView.snp.makeConstraints { make in
            make.top.directionalHorizontalEdges.equalToSuperview().inset(12)
        }

        memoLimitLabel.snp.makeConstraints { make in
            make.top.equalTo(memoTextView.snp.bottom).offset(12)
            make.bottom.directionalHorizontalEdges.equalToSuperview().inset(12)
        }
    }
}
