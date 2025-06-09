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
        case folder(FolderCellDisplay)
        case clip(ClipCellDisplay)
    }

    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>?
    private let disposeBag = DisposeBag()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: createLayout(),
        )
        collectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "SectionHeaderView",
        )
        collectionView.register(
            FolderCell.self,
            forCellWithReuseIdentifier: "FolderCell",
        )
        collectionView.register(
            ClipCell.self,
            forCellWithReuseIdentifier: "ClipCell",
        )
        return collectionView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setDisplay(folders: [FolderCellDisplay], clips: [ClipCellDisplay]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.folder, .clip])
        snapshot.appendItems(folders.map { .folder($0) }, toSection: .folder)
        snapshot.appendItems(clips.map { .clip($0) }, toSection: .clip)

        dataSource?.apply(snapshot, animatingDifferences: true)
    }

    private func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { _, _ in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0),
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(72)
            )
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

            let sectionLayout = NSCollectionLayoutSection(group: group)
            sectionLayout.interGroupSpacing = 8
            sectionLayout.contentInsets = .init(top: 0, leading: 24, bottom: 0, trailing: 24)

            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(44)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            sectionLayout.boundarySupplementaryItems = [header]

            return sectionLayout
        }
    }
}

private extension FolderView {
    func configure() {
        setHierarchy()
        setConstraints()
        setDataSource()
    }

    func setHierarchy() {
        addSubview(collectionView)
    }

    func setConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
    }

    func setDataSource() {
        dataSource = .init(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .folder(let folderDisplay):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "FolderCell",
                    for: indexPath,
                ) as? FolderCell else { return UICollectionViewCell() }
                cell.setDisplay(folderDisplay)

                return cell
            case .clip(let clipDisplay):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "ClipCell",
                    for: indexPath,
                ) as? ClipCell else { return UICollectionViewCell() }
                cell.setDisplay(clipDisplay)

                return cell
            }
        }

        dataSource?.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader,
                  let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: "SectionHeaderView",
                    for: indexPath,
                  ) as? SectionHeaderView else { return nil }
            header.setTitle(indexPath.section == 0 ? "폴더" : "클립")

            return header
        }
    }
}
