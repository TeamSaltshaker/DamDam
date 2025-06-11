import SnapKit
import UIKit

final class TableHeaderView: UITableViewHeaderFooterView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendard(size: 18, weight: .semiBold)
        return label
    }()

    override init(reuseIdentifier: String?) {
         super.init(reuseIdentifier: reuseIdentifier)
         configure()
     }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setTitle(_ title: String) {
        titleLabel.text = title
    }
}

private extension TableHeaderView {
    func configure() {
        setHierarchy()
        setConstraints()
    }

    func setHierarchy() {
        [titleLabel].forEach { addSubview($0) }
    }

    func setConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(4)
            make.bottom.equalToSuperview().inset(8)
        }
    }
}
