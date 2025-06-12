import RxCocoa
import RxSwift
import SnapKit
import UIKit

final class UnvisitedClipListView: UIView {
    enum Action {
        case tapBack
        case tapCell(Int)
        case detail(Int)
        case edit(Int)
        case delete(Int)
    }

    typealias Section = Int
    typealias Item = ClipDisplay

    private let disposeBag = DisposeBag()
    let action = PublishRelay<Action>()

    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>?

    private lazy var navigationView: CommonNavigationView = {
        let view = CommonNavigationView()
        view.setTitle("방문하지 않은 클립")
        view.setLeftItem(backButton)
        return view
    }()

    private let backButton = BackButton()

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
        let clipCellRegistration = UICollectionView.CellRegistration<ClipListCell, ClipDisplay> { cell, _, item in
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

    func setDisplay(_ display: [ClipDisplay]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([0])
        snapshot.appendItems(display)
        dataSource?.apply(snapshot)
    }
}

private extension UnvisitedClipListView {
    func createCollectionViewLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] _, env in
            guard let self else { return nil }

            var config = UICollectionLayoutListConfiguration(appearance: .plain)
            config.showsSeparators = false
            config.backgroundColor = .white800
            config.trailingSwipeActionsConfigurationProvider = { indexPath in
                let delete = UIContextualAction(
                    style: .destructive,
                    title: "삭제"
                ) { _, _, completion in
                    self.action.accept(.delete(indexPath.item))
                    completion(true)
                }

                delete.image = .trashWhite
                delete.backgroundColor = .red600

                return UISwipeActionsConfiguration(actions: [delete])
            }
            let section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: env)
            section.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 24)
            section.interGroupSpacing = 8

            return section
        }
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

extension UnvisitedClipListView {
    func collectionView(
        _ collectionView: UICollectionView,
        trailingSwipeActionsConfigurationForItemAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(
            style: .destructive,
            title: nil
        ) { [weak self] _, _, completion in
            guard let self = self else { return }
            action.accept(.delete(indexPath.row))
            completion(true)
        }

        delete.image = UIImage(systemName: "trash")
        delete.backgroundColor = .systemRed

        return UISwipeActionsConfiguration(actions: [delete])
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
        backgroundColor = .white800
    }

    func setHierarchy() {
        [
            navigationView,
            collectionView
        ].forEach { addSubview($0) }
    }

    func setConstraints() {
        navigationView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(56)
        }

        backButton.snp.makeConstraints { make in
            make.size.equalTo(44)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    func setBindings() {
        backButton.rx.tap
            .map { Action.tapBack }
            .bind(to: action)
            .disposed(by: disposeBag)

        collectionView.rx.itemSelected
            .map { Action.tapCell($0.item) }
            .bind(to: action)
            .disposed(by: disposeBag)
    }
}
