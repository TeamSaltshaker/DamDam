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

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: createCollectionViewLayout()
        )
        collectionView.delegate = self
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
//        let clipCellRegistration = UICollectionView.CellRegistration<ClipGridCell, ClipDisplay> { cell, _, item in
//            cell.setDisplay(item)
//        }
//
//        let folderCellRegistration = UICollectionView.CellRegistration<FolderCell, FolderDisplay> { cell, _, item in
//            cell.setDisplay(item)
//        }
//
//        dataSource = .init(collectionView: collectionView) { collectionView, indexPath, item in
//            switch item {
//            case .clip(let clipItem):
//                collectionView.dequeueConfiguredReusableCell(
//                    using: clipCellRegistration,
//                    for: indexPath,
//                    item: clipItem
//                )
//            case .folder(let folderItem):
//                collectionView.dequeueConfiguredReusableCell(
//                    using: folderCellRegistration,
//                    for: indexPath,
//                    item: folderItem
//                )
//            }
//        }
//
//        let headerRegistration = UICollectionView.SupplementaryRegistration<SectionHeaderView>(
//            elementKind: UICollectionView.elementKindSectionHeader
//        ) { header, _, indexPath in
//            guard let section = Section(rawValue: indexPath.section) else { return }
//            switch section {
//            case .clip:
//                header.setTitle("방문하지 않은 클립")
//                header.setShowAllButtonVisible(true)
//
//                header.showAllTapped
//                    .map { Action.showAllClips }
//                    .bind(to: self.action)
//                    .disposed(by: self.disposeBag)
//            case .folder:
//                header.setTitle("폴더")
//            }
//        }
//
//        dataSource?.supplementaryViewProvider = { collectionView, _, indexPath in
//            collectionView.dequeueConfiguredReusableSupplementary(
//                using: headerRegistration,
//                for: indexPath
//            )
//        }
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
        snapshot.appendSections(Section.allCases)

        let clipItems = display.unvitsedClips.map { Item.clip($0) }
        let folderItems = display.folders.map { Item.folder($0) }

        snapshot.appendItems(clipItems, toSection: .clip)
        snapshot.appendItems(folderItems, toSection: .folder)
        dataSource?.apply(snapshot)
    }
}

private extension HomeView {
    func createCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout(
            sectionProvider: { [weak self] (index, _) -> NSCollectionLayoutSection? in
                guard let self,
                      let section = Section(rawValue: index)
                else { return nil }

                return self.makeSectionLayout(for: section)
            },
            configuration: {
                let config = UICollectionViewCompositionalLayoutConfiguration()
                config.interSectionSpacing = 24
                return config
            }()
        )

        return layout
    }

    func makeSectionLayout(for section: Section) -> NSCollectionLayoutSection {
        let layoutSection: NSCollectionLayoutSection

        switch section {
        case .clip:
            layoutSection = makeClipSectionLayout()
        case .folder:
            layoutSection = makeFolderSectionLayout()
        }

        let header = makeHeaderItemLayout()
        layoutSection.boundarySupplementaryItems = [header]

        return layoutSection
    }

    func makeClipSectionLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(144),
            heightDimension: .absolute(179)
        )

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        section.interGroupSpacing = 16
        section.contentInsets = .init(top: 24, leading: 24, bottom: 0, trailing: 24)

        return section
    }

    func makeFolderSectionLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(72)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = .init(top: 0, leading: 24, bottom: 0, trailing: 24)

        return section
    }

    func makeHeaderItemLayout() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(48)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        header.contentInsets = .init(top: 0, leading: 12, bottom: 0, trailing: 0)

        return header
    }
}

extension HomeView: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let item = dataSource?.itemIdentifier(for: indexPath) else { return nil }

        return UIContextMenuConfiguration(
            identifier: indexPath as NSCopying,
            previewProvider: nil
        ) { _ in
            var actions: [UIAction] = []

            switch item {
            case .clip:
                let info = UIAction(
                    title: "상세정보",
                    image: UIImage(systemName: "magnifyingglass")
                ) { [weak self] _ in
                    self?.action.accept(.detail(indexPath))
                }
                actions.append(info)
                fallthrough
            case .folder:
                let edit = UIAction(
                    title: "편집",
                    image: UIImage(systemName: "pencil")
                ) { [weak self] _ in
                    self?.action.accept(.edit(indexPath))
                }

                let delete = UIAction(
                    title: "삭제",
                    image: UIImage(systemName: "trash"),
                    attributes: .destructive
                ) { [weak self] _ in
                    self?.action.accept(.delete(indexPath))
                }

                actions.append(contentsOf: [edit, delete])
            }

            return UIMenu(title: "", children: actions)
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
        backgroundColor = .systemBackground
    }

    func setHierarchy() {
        [
            collectionView,
            navigationView
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
