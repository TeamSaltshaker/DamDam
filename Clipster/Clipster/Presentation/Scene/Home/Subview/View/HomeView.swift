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

    enum Section: Int, CaseIterable {
        case clip
        case folder
    }

    enum Item: Hashable {
        case clip(ClipDisplay)
        case folder(FolderDisplay)
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
        attributedText.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: NSRange(location: 0, length: 1))
        attributedText.addAttribute(.foregroundColor, value: UIColor.systemYellow, range: NSRange(location: 1, length: 1))

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
            print(item)
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
                let sectionIdentifier = dataSource?.snapshot().sectionIdentifiers[indexPath.section]
            else { return }

            switch sectionIdentifier {
            case .clip:
                header.setTitle("방문하지 않은 클립")
                header.setShowAllButtonVisible(true)

                header.showAllTapped
                    .map { Action.showAllClips }
                    .bind(to: action)
                    .disposed(by: disposeBag)
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

        if !display.unvitsedClips.isEmpty {
            let clipItems = display.unvitsedClips.map { Item.clip($0) }
            snapshot.appendSections([.clip])
            snapshot.appendItems(clipItems, toSection: .clip)
        }

        if !display.folders.isEmpty {
            let folderItems = display.folders.map { Item.folder($0) }
            snapshot.appendSections([.folder])
            snapshot.appendItems(folderItems, toSection: .folder)
        }

        dataSource?.apply(snapshot)
    }
}

private extension HomeView {
    func createCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] index, env -> NSCollectionLayoutSection? in
            guard let self,
                  let sectionKind = self.dataSource?.snapshot().sectionIdentifiers[index]
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
        config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self,
                  let item = self.dataSource?.itemIdentifier(for: indexPath),
                  case .folder = item
            else {
                return nil
            }

            let delete = UIContextualAction(
                style: .destructive,
                title: "삭제"
            ) { _, _, completion in
                self.action.accept(.delete(indexPath))
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
            heightDimension: .absolute(28)
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
            guard let self else { return UIMenu() }
            let detail = makeDetailAction(for: indexPath)
            let edit = makeEditAction(for: indexPath)
            let delete = makeDeleteAction(for: indexPath)

            return UIMenu(title: "", children: [detail, edit, delete])
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
        backgroundColor = .white800
    }

    func setHierarchy() {
        [
            navigationView,
            collectionView
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
            make.size.equalTo(44)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    func setBindings() {
        collectionView.rx.itemSelected
            .map { Action.tapCell($0) }
            .bind(to: action)
            .disposed(by: disposeBag)
    }
}
