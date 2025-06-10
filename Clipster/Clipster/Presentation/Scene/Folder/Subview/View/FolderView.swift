import RxCocoa
import RxSwift
import SnapKit
import UIKit

final class FolderView: UIView {
    enum Section: Int {
        case folder
        case clip
    }

    enum Item: Hashable {
        case folder(FolderDisplay)
        case clip(ClipDisplay)
    }

    let didTapCell = PublishRelay<IndexPath>()
    let didTapDetailButton = PublishRelay<IndexPath>()
    let didTapEditButton = PublishRelay<IndexPath>()
    let didTapDeleteButton = PublishRelay<(IndexPath, String)>()

    private var dataSource: UITableViewDiffableDataSource<Section, Item>?
    private let disposeBag = DisposeBag()

    let navigationView = CommonNavigationView()
    let backButton = BackButton()
    let addButton = AddButton()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(FolderCell.self, forCellReuseIdentifier: FolderCell.identifier)
        tableView.register(ClipCell.self, forCellReuseIdentifier: ClipCell.identifier)
        tableView.delegate = self
        return tableView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setDisplay(folders: [FolderDisplay], clips: [ClipDisplay]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.folder, .clip])
        snapshot.appendItems(folders.map { .folder($0) }, toSection: .folder)
        snapshot.appendItems(clips.map { .clip($0) }, toSection: .clip)

        dataSource?.apply(snapshot, animatingDifferences: true)
    }
}

private extension FolderView {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
        setBindings()
        setDataSource()
    }

    func setAttributes() {
        navigationView.setLeftItem(backButton)
        navigationView.setRightItem(addButton)
    }

    func setHierarchy() {
        [navigationView, tableView].forEach {
            addSubview($0)
        }
    }

    func setConstraints() {
        navigationView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.directionalHorizontalEdges.equalToSuperview()
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.directionalHorizontalEdges.bottom.equalTo(safeAreaLayoutGuide)
        }
    }

    func setDataSource() {
        dataSource = .init(tableView: tableView) { tableView, indexPath, item in
            switch item {
            case .folder(let folderDisplay):
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: FolderCell.identifier,
                    for: indexPath,
                ) as? FolderCell else { return UITableViewCell() }
                cell.setDisplay(folderDisplay)

                return cell
            case .clip(let clipDisplay):
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: ClipCell.identifier,
                    for: indexPath,
                ) as? ClipCell else { return UITableViewCell() }
                cell.setDisplay(clipDisplay)

                return cell
            }
        }
    }

    func setBindings() {
        tableView.rx.itemSelected
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] indexPath in
                guard let self else { return }
                tableView.deselectRow(at: indexPath, animated: true)
                didTapCell.accept(indexPath)
            }
            .disposed(by: disposeBag)
    }
}

extension FolderView: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int,
    ) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear

        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .label
        label.text = section == 0 ? "폴더" : "클립"
        headerView.addSubview(label)

        label.snp.makeConstraints { make in
            make.directionalHorizontalEdges.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }

        return headerView
    }

    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int,
    ) -> CGFloat {
        44
    }

    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint,
    ) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self else { return UIMenu() }

            let detailAction = UIAction(
                title: "상세정보",
                image: UIImage(systemName: "info.circle"),
            ) { _ in
                self.didTapDetailButton.accept(indexPath)
            }
            let editAction = UIAction(
                title: "편집",
                image: UIImage(systemName: "pencil"),
            ) { _ in
                self.didTapEditButton.accept(indexPath)
            }
            let deleteAction = UIAction(
                title: "삭제",
                image: UIImage(systemName: "trash"),
                attributes: .destructive,
            ) { _ in
                guard let item = self.dataSource?.itemIdentifier(for: indexPath) else { return }

                switch item {
                case .folder(let display):
                    self.didTapDeleteButton.accept((indexPath, display.title))
                case .clip(let display):
                    self.didTapDeleteButton.accept((indexPath, display.urlMetadata.title))
                }
            }
            let actions = (indexPath.section == 0 ? [] : [detailAction]) + [editAction, deleteAction]

            return UIMenu(title: "", children: actions)
        }
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath,
    ) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "삭제",
        ) { [weak self] _, _, completion in
            guard let self,
                  let item = dataSource?.itemIdentifier(for: indexPath) else {
                completion(false)
                return
            }

            switch item {
            case .folder(let display):
                didTapDeleteButton.accept((indexPath, display.title))
            case .clip(let display):
                didTapDeleteButton.accept((indexPath, display.urlMetadata.title))
            }

            completion(true)
        }
        deleteAction.image = .init(systemName: "trash.fill")

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false

        return configuration
    }
}
