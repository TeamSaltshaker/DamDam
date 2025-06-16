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
        case delete(indexPath: IndexPath, title: String)
        case showAllClips
    }

    enum Section: Int, CaseIterable {
        case clip
        case folder

        func logicalIndexPath(for item: Int) -> IndexPath {
            switch self {
            case .clip:
                return IndexPath(item: item, section: 0)
            case .folder:
                return IndexPath(item: item, section: 1)
            }
        }
    }

    enum Item: Hashable {
        case clip(ClipDisplay)
        case folder(FolderDisplay)

        var displayTitle: String {
            switch self {
            case .clip(let clip): clip.urlMetadata.title
            case .folder(let folder): folder.title
            }
        }
    }

    private let disposeBag = DisposeBag()
    let action = PublishRelay<Action>()

    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>?

    private let navigationView = UIView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        let text = "담담"
        let font = UIFont(name: "locus_sangsang", size: 28) ?? UIFont.boldSystemFont(ofSize: 28)
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttributes([
            .foregroundColor: UIColor.blue600,
            .font: font
        ], range: NSRange(location: 0, length: 1))

        attributedText.addAttributes([
            .foregroundColor: UIColor.blue700,
            .font: font
        ], range: NSRange(location: 1, length: 1))
        label.attributedText = attributedText

        return label
    }()

    private lazy var addButton: AddButton = {
        let button = AddButton()
        button.showsMenuAsPrimaryAction = true
        button.menu = makeAddButtonMenu()
        return button
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: createCollectionViewLayout()
        )
        collectionView.delegate = self
        collectionView.contentInset.top = 24
        collectionView.backgroundColor = .white800
        return collectionView
    }()

    private let emptyView: EmptyView = {
        let view = EmptyView(type: .homeView)
        view.isHidden = true
        return view
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        configureDataSource()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureDataSource() {
        let clipCellRegistration = UICollectionView.CellRegistration<ClipGridCell, ClipDisplay> { cell, _, item in
            cell.setDisplay(item)
        }

        let folderCellRegistration = UICollectionView.CellRegistration<FolderListCell, FolderDisplay> { cell, _, item in
            cell.setDisplay(item)
        }

        dataSource = .init(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .clip(let clipItem):
                return collectionView.dequeueConfiguredReusableCell(
                    using: clipCellRegistration,
                    for: indexPath,
                    item: clipItem
                )
            case .folder(let folderItem):
                return collectionView.dequeueConfiguredReusableCell(
                    using: folderCellRegistration,
                    for: indexPath,
                    item: folderItem
                )
            }
        }

        let headerRegistration = UICollectionView.SupplementaryRegistration<CollectionHeaderView>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [weak self] header, _, indexPath in
            guard
                let self,
                let sectionIdentifier = dataSource?.sectionIdentifier(for: indexPath.section)
            else { return }

            switch sectionIdentifier {
            case .clip:
                header.setTitle("방문하지 않은 클립")
                header.setShowAllButtonVisible(true)
                header.setBindings()

                header.showAllTapped
                    .map { Action.showAllClips }
                    .bind(to: action)
                    .disposed(by: header.disposeBag)
            case .folder:
                header.setTitle("폴더")
            }
        }

        dataSource?.supplementaryViewProvider = { collectionView, _, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary(
                using: headerRegistration,
                for: indexPath
            )
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
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()

        if !display.unvisitedClips.isEmpty {
            let clipItems = display.unvisitedClips.map { Item.clip($0) }
            snapshot.appendSections([.clip])
            snapshot.appendItems(clipItems, toSection: .clip)
        }

        if !display.folders.isEmpty {
            let folderItems = display.folders.map { Item.folder($0) }
            snapshot.appendSections([.folder])
            snapshot.appendItems(folderItems, toSection: .folder)
        }

        let isEmptyViewHidden = !(display.unvisitedClips.isEmpty && display.folders.isEmpty)
        emptyView.isHidden = isEmptyViewHidden

        dataSource?.apply(snapshot, animatingDifferences: false)
    }

    func showLoading() {
        loadingIndicator.startAnimating()
        isUserInteractionEnabled = false
    }

    func hideLoading() {
        loadingIndicator.stopAnimating()
        isUserInteractionEnabled = true
    }
}

private extension HomeView {
    func createCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] index, env -> NSCollectionLayoutSection? in
            guard let self,
                  let sectionKind = dataSource?.sectionIdentifier(for: index)
            else { return nil }

            switch sectionKind {
            case .clip:
                return makeClipSectionLayout()
            case .folder:
                return makeFolderListSectionLayout(using: env)
            }
        }
        return layout
    }

    func makeClipSectionLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(144),
            heightDimension: .absolute(185.94)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        section.interGroupSpacing = 16
        section.contentInsets = .init(top: 16, leading: 24, bottom: 24, trailing: 24)
        section.boundarySupplementaryItems = [makeHeaderItemLayout(for: .clip)]

        return section
    }

    func makeFolderListSectionLayout(using env: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.showsSeparators = false
        config.backgroundColor = .white800
        config.headerMode = .supplementary
        config.headerTopPadding = 0
        config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            let delete = UIContextualAction(
                style: .destructive,
                title: "삭제"
            ) { [weak self] _, _, completion in
                self?.performAction(for: indexPath) { .delete(indexPath: $0, title: $1.displayTitle) }
                completion(true)
            }

            delete.image = .trashWhite
            delete.backgroundColor = .red600

            return UISwipeActionsConfiguration(actions: [delete])
        }
            let section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: env)
            section.boundarySupplementaryItems = [makeHeaderItemLayout(for: .folder)]
            section.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 24)
            section.interGroupSpacing = 8
            return section
        }

        func makeHeaderItemLayout(for section: Section) -> NSCollectionLayoutBoundarySupplementaryItem {
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(48)
            )

            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )

            switch section {
            case .clip:
                header.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
            case .folder:
                header.contentInsets = .init(top: 0, leading: 24, bottom: 8, trailing: 24)
            }

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
            guard let self,
                  let item = self.dataSource?.itemIdentifier(for: indexPath)
            else {
                return UIMenu()
            }

            let edit = self.makeEditAction(for: indexPath)
            let delete = self.makeDeleteAction(for: indexPath)

            switch item {
            case .clip:
                let detail = self.makeDetailAction(for: indexPath)
                return UIMenu(title: "", children: [detail, edit, delete])
            case .folder:
                return UIMenu(title: "", children: [edit, delete])
            }
        }
    }
}

private extension HomeView {
    private func makeDetailAction(for indexPath: IndexPath) -> UIAction {
        .init(
            title: "상세정보",
            image: UIImage(systemName: "magnifyingglass")
        ) { [weak self] _ in
            self?.performAction(for: indexPath) { .detail($0) }
        }
    }

    func makeEditAction(for indexPath: IndexPath) -> UIAction {
        .init(
            title: "편집",
            image: UIImage(systemName: "pencil")
        ) { [weak self] _ in
            self?.performAction(for: indexPath) { .edit($0) }
        }
    }

    func makeDeleteAction(for indexPath: IndexPath) -> UIAction {
        .init(
            title: "삭제",
            image: UIImage(systemName: "trash"),
            attributes: .destructive
        ) { [weak self] _ in
            self?.performAction(for: indexPath) { .delete(indexPath: $0, title: $1.displayTitle) }
        }
    }
}

private extension HomeView {
    func performAction(
        for indexPath: IndexPath,
        transform: (IndexPath, Item) -> Action
    ) {
        guard let item = dataSource?.itemIdentifier(for: indexPath) else { return }
        let logical = logicalIndexPath(indexPath)
        action.accept(transform(logical, item))
    }

    func performAction(
        for indexPath: IndexPath,
        transform: (IndexPath) -> Action
    ) {
        let logical = logicalIndexPath(indexPath)
        action.accept(transform(logical))
    }

    func logicalIndexPath(_ indexPath: IndexPath) -> IndexPath {
        guard let section = self.dataSource?.sectionIdentifier(for: indexPath.section)
        else { return indexPath }

        return section.logicalIndexPath(for: indexPath.item)
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
        backgroundColor = .white800
    }

    func setHierarchy() {
        [
            navigationView,
            collectionView,
            emptyView,
            loadingIndicator
        ].forEach { addSubview($0) }

        [
            titleLabel,
            addButton
        ].forEach { navigationView.addSubview($0) }
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
            make.size.equalTo(48)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        emptyView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    func setBindings() {
        collectionView.rx.itemSelected
            .map { [weak self] indexPath in
                self?.logicalIndexPath(indexPath) ?? indexPath
            }
            .map { Action.tapCell($0) }
            .bind(to: action)
            .disposed(by: disposeBag)
    }
}
