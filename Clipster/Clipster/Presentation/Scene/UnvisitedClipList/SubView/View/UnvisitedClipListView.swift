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

    private var dataSource: UITableViewDiffableDataSource<Section, Item>?

    private lazy var navigationView: CommonNavigationView = {
        let view = CommonNavigationView()
        view.setTitle("방문하지 않은 클립")
        view.setLeftItem(backButton)
        return view
    }()

    private let backButton = BackButton()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = #colorLiteral(red: 0.9813517928, green: 0.9819430709, blue: 1, alpha: 1)
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.rowHeight = 72
        tableView.register(ClipCell.self, forCellReuseIdentifier: ClipCell.identifier)
        tableView.delegate = self
        return tableView
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
        dataSource = .init(tableView: tableView) { tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ClipCell.identifier,
                for: indexPath
            ) as? ClipCell
            else { return UITableViewCell() }
            cell.setDisplay(item)
            return cell
        }
    }

    func setDisplay(_ display: [ClipDisplay]) {
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
            section.contentInsets = .init(top: 24, leading: 24, bottom: 0, trailing: 24)
            return section
        }

        return layout
    }
}

extension UnvisitedClipListView: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
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
        [
            tableView,
            navigationView
        ].forEach { addSubview($0) }
    }

    func setConstraints() {
        navigationView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(56)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    func setBindings() {
        tableView.rx.itemSelected
            .map { Action.tapCell($0.row) }
            .bind(to: action)
            .disposed(by: disposeBag)

        backButton.rx.tap
            .map { Action.tapBack }
            .bind(to: action)
            .disposed(by: disposeBag)
    }
}
