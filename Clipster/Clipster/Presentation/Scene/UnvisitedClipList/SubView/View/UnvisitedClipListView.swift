import RxCocoa
import RxSwift
import SnapKit
import UIKit

final class UnvisitedClipListView: UIView {
    enum Action {
        case tap(Int)
        case detail(Int)
        case edit(Int)
        case delete(Int)
    }

    typealias Section = Int
    typealias Item = ClipCellDisplay

    private let disposeBag = DisposeBag()
    let action = PublishRelay<Action>()

    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>?

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
        let clipCellRegistration = UICollectionView.CellRegistration<ClipCell, ClipCellDisplay> { cell, _, item in
            cell.setDisplay(item)
        }

        dataSource = .init(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(
                using: clipCellRegistration,
                for: indexPath,
                item: item
            )
        }
    }

    func setDisplay(_ display: [ClipCellDisplay]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([0])
        snapshot.appendItems(display, toSection: 0)
        dataSource?.apply(snapshot)
    }
}

private extension UnvisitedClipListView {
    func createCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(72)
            )
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: groupSize,
                subitems: [item]
            )

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 8
            section.contentInsets = NSDirectionalEdgeInsets(top: 24, leading: 24, bottom: 0, trailing: 24)
            return section
        }

        return layout
    }
}

extension UnvisitedClipListView: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(
            identifier: indexPath as NSCopying,
            previewProvider: nil
        ) { _ in
            let info = UIAction(
                title: "상세정보",
                image: UIImage(systemName: "magnifyingglass")
            ) { [weak self] _ in
                self?.action.accept(.detail(indexPath.item))
            }

            let edit = UIAction(
                title: "편집",
                image: UIImage(systemName: "pencil")
            ) { [weak self] _ in
                self?.action.accept(.edit(indexPath.item))
            }

            let delete = UIAction(
                title: "삭제",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { [weak self] _ in
                self?.action.accept(.delete(indexPath.item))
            }

        return UIMenu(title: "", children: [info, edit, delete])
        }
    }
}

private extension UnvisitedClipListView {
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
        addSubview(collectionView)
    }

    func setConstraints() {
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    func setBindings() {
        collectionView.rx.itemSelected
            .map { Action.tap($0.row) }
            .bind(to: action)
            .disposed(by: disposeBag)
    }
}
