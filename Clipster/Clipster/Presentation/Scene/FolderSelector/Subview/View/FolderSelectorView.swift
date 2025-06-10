import SnapKit
import UIKit

final class FolderSelectorView: UIView {
    let folderSelectorNavigationView = FolderSelectorNavigationView()

    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        return view
    }()

    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(FolderCell.self, forCellReuseIdentifier: FolderCell.identifier)
        tableView.rowHeight = 72
        tableView.separatorStyle = .none
        return tableView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        self.backgroundColor = .systemBackground

        [folderSelectorNavigationView, separator, tableView]
            .forEach { addSubview($0) }

        folderSelectorNavigationView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(19)
            make.directionalHorizontalEdges.equalToSuperview()
            make.height.equalTo(84)
        }

        separator.snp.makeConstraints { make in
            make.top.equalTo(folderSelectorNavigationView.snp.bottom)
            make.directionalHorizontalEdges.equalToSuperview()
            make.height.equalTo(0.7)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(separator.snp.bottom)
            make.bottom.directionalHorizontalEdges.equalToSuperview()
        }
    }
}
