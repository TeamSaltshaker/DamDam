import SnapKit
import UIKit

final class FolderSelectorView: UIView {
    let commonNavigationView: CommonNavigationView = {
        let commonNavigationView = CommonNavigationView()
        commonNavigationView.backgroundColor = .white900
        return commonNavigationView
    }()

    let backButton = BackButton("이전폴더")
    let selectButton = SelectButton()

    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .black800
        return view
    }()

    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(FolderSelectorCell.self, forCellReuseIdentifier: FolderSelectorCell.identifier)
        tableView.rowHeight = 72
        tableView.separatorStyle = .none
        return tableView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension FolderSelectorView {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        backgroundColor = .white900

        commonNavigationView.setLeftItem(backButton)
        commonNavigationView.setRightItem(selectButton)
    }

    func setHierarchy() {
        [commonNavigationView, separator, tableView]
            .forEach { addSubview($0) }
    }

    func setConstraints() {
        commonNavigationView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.directionalHorizontalEdges.equalToSuperview()
        }

        backButton.snp.makeConstraints { make in
            make.height.equalTo(48)
        }

        selectButton.snp.makeConstraints { make in
            make.size.equalTo(48)
        }

        separator.snp.makeConstraints { make in
            make.top.equalTo(commonNavigationView.snp.bottom).offset(14)
            make.directionalHorizontalEdges.equalToSuperview()
            make.height.equalTo(1)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(separator.snp.bottom)
            make.bottom.directionalHorizontalEdges.equalToSuperview()
        }
    }
}
