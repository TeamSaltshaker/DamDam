import RxCocoa
import RxSwift
import SnapKit
import UIKit

final class HomeView: UIView {
    enum Action {
        case tapAddFolder
        case tapAddClip
        case tapCell(IndexPath)
        case detail(IndexPath)
        case edit(IndexPath)
        case delete(IndexPath)
        case showAllClips
    }

    private let disposeBag = DisposeBag()
    let action = PublishRelay<Action>()

    private var collectionDataSource: UICollectionViewDiffableDataSource<Int, ClipDisplay>?
    private var tableDataSource: UITableViewDiffableDataSource<Int, FolderDisplay>?

    private var tableViewHeightConstraint: Constraint?

    private let navigationView = UIView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "아차차"
        label.font = .systemFont(ofSize: 28, weight: .heavy)
        label.textColor = .label
        return label
    }()

    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .label
        button.showsMenuAsPrimaryAction = true
        button.menu = makeAddButtonMenu()
        return button
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    let contentView = UIView()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: createCollectionViewLayout()
        )
        collectionView.delegate = self
        collectionView.contentInset.top = 24
        collectionView.backgroundColor = #colorLiteral(red: 0.9813517928, green: 0.9819430709, blue: 1, alpha: 1)
        return collectionView
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = #colorLiteral(red: 0.9813517928, green: 0.9819430709, blue: 1, alpha: 1)
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.rowHeight = 72
        tableView.register(FolderCell.self, forCellReuseIdentifier: FolderCell.identifier)
        tableView.isScrollEnabled = false
        tableView.delegate = self
        return tableView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        configureCollectionDataSource()
        configureTableDataSource()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureCollectionDataSource() {
        let clipCellRegistration = UICollectionView.CellRegistration<ClipGridCell, ClipDisplay> { cell, _, item in
            cell.setDisplay(item)
        }

        collectionDataSource = .init(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(
                using: clipCellRegistration,
                for: indexPath,
                item: item
            )
        }

        let headerRegistration = UICollectionView.SupplementaryRegistration<SectionHeaderView>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { header, _, _ in
            header.setTitle("방문하지 않은 클립")
            header.setShowAllButtonVisible(true)

            header.showAllTapped
                .map { Action.showAllClips }
                .bind(to: self.action)
                .disposed(by: self.disposeBag)
        }

        collectionDataSource?.supplementaryViewProvider = { collectionView, _, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary(
                using: headerRegistration,
                for: indexPath
            )
        }
    }

    private func configureTableDataSource() {
        tableDataSource = UITableViewDiffableDataSource<Int, FolderDisplay>(
            tableView: tableView
        ) { tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: FolderCell.identifier,
                for: indexPath
            ) as? FolderCell
            else { return UITableViewCell() }
            cell.setDisplay(item)
            return cell
        }
    }

    private func makeAddButtonMenu() -> UIMenu {
        let addFolderAction = UIAction(
            title: "폴더 추가",
            image: UIImage(systemName: "folder")
        ) { [weak self] _ in
            self?.action.accept(.tapAddFolder)
        }

        let addClipAction = UIAction(
            title: "클립 추가",
            image: UIImage(systemName: "paperclip"),
        ) { [weak self] _ in
            self?.action.accept(.tapAddClip)
        }

        return UIMenu(title: "", children: [addFolderAction, addClipAction])
    }

    func setDisplay(_ display: HomeDisplay) {
        var collectionSnapshot = NSDiffableDataSourceSnapshot<Int, ClipDisplay>()
        collectionSnapshot.appendSections([0])
        collectionSnapshot.appendItems(display.unvitsedClips)
        collectionDataSource?.apply(collectionSnapshot)

        var tableSnapshot = NSDiffableDataSourceSnapshot<Int, FolderDisplay>()
        tableSnapshot.appendSections([0])
        tableSnapshot.appendItems(display.folders)
        tableDataSource?.apply(tableSnapshot, animatingDifferences: true) { [weak self] in
            guard let self else { return }
            let newHeight = tableView.contentSize.height
            tableViewHeightConstraint?.update(offset: newHeight)
        }
    }
}

private extension HomeView {
    func createCollectionViewLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(144),
            heightDimension: .absolute(179)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        section.interGroupSpacing = 16
        section.contentInsets = .init(top: 16, leading: 24, bottom: 0, trailing: 24)

        let header = makeHeaderItemLayout()
        section.boundarySupplementaryItems = [header]

        return UICollectionViewCompositionalLayout(section: section)
    }

    func makeHeaderItemLayout() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(28)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )

        return header
    }
}

extension HomeView: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        .init(
            identifier: indexPath as NSCopying,
            previewProvider: nil
        ) { [weak self] _ in
            guard let self else { return UIMenu() }
            let detail = makeDetailAction(for: indexPath)
            let edit = makeEditAction(for: indexPath)
            let delete = makeDeleteAction(for: indexPath)

            return UIMenu(title: "", children: [detail, edit, delete])
        }
    }
}

extension HomeView: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
            guard let self = self else { return }
            action.accept(.delete(indexPath))
            completion(true)
        }

        delete.image = UIImage(systemName: "trash")
        delete.backgroundColor = .systemRed

        return UISwipeActionsConfiguration(actions: [delete])
    }
}

extension HomeView {
    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        .init(
            identifier: indexPath as NSCopying,
            previewProvider: nil
        ) { [weak self] _ in
            guard let self else { return UIMenu() }
            let edit = makeEditAction(for: indexPath)
            let delete = makeDeleteAction(for: indexPath)

            return UIMenu(title: "", children: [edit, delete])
        }
    }
}

private extension HomeView {
    private func makeDetailAction(for indexPath: IndexPath) -> UIAction {
        .init(
            title: "상세정보",
            image: UIImage(systemName: "magnifyingglass")
        ) { [weak self] _ in
            self?.action.accept(.detail(indexPath))
        }
    }

    func makeEditAction(for indexPath: IndexPath) -> UIAction {
        .init(
            title: "편집",
            image: UIImage(systemName: "pencil")
        ) { [weak self] _ in
            self?.action.accept(.edit(indexPath))
        }
    }

    func makeDeleteAction(for indexPath: IndexPath) -> UIAction {
        .init(
            title: "삭제",
            image: UIImage(systemName: "trash"),
            attributes: .destructive
        ) { [weak self] _ in
            self?.action.accept(.delete(indexPath))
        }
    }
}

private extension HomeView {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
        setBindings()
    }

    func setAttributes() {
        backgroundColor = #colorLiteral(red: 0.9813517928, green: 0.9819430709, blue: 1, alpha: 1)
    }

    func setHierarchy() {
        [
            navigationView,
            scrollView
        ].forEach { addSubview($0) }

        [
            titleLabel,
            addButton
        ].forEach { navigationView.addSubview($0) }

        [contentView].forEach { scrollView.addSubview($0) }

        [
            collectionView,
            tableView
        ].forEach { contentView.addSubview($0) }
    }

    func setConstraints() {
        navigationView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(56)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24)
            make.centerY.equalToSuperview()
        }

        addButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(24)
            make.centerY.equalToSuperview()
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        contentView.snp.makeConstraints {
            $0.verticalEdges.equalTo(scrollView.contentLayoutGuide)
            $0.horizontalEdges.equalTo(scrollView.frameLayoutGuide)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(263)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
            self.tableViewHeightConstraint = make.height.equalTo(0).constraint
        }
    }

    func setBindings() {
        collectionView.rx.itemSelected
            .map { Action.tapCell($0) }
            .bind(to: action)
            .disposed(by: disposeBag)
    }
}
