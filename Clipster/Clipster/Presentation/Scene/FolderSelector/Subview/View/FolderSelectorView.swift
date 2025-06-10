import SnapKit
import UIKit

final class FolderSelectorView: UIView {
    private let folderSelectorNavigationView = FolderSelectorNavigationView()

    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(FolderSelectorCell.self, forCellReuseIdentifier: FolderSelectorCell.identifier)
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

        [folderSelectorNavigationView, tableView]
            .forEach { addSubview($0) }

        folderSelectorNavigationView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(19.5)
            make.directionalHorizontalEdges.equalToSuperview()
            make.height.equalTo(84)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(folderSelectorNavigationView.snp.bottom)
            make.bottom.directionalHorizontalEdges.equalToSuperview()
        }
    }
}
