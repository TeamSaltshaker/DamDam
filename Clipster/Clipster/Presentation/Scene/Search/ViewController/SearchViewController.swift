import ReactorKit
import RxCocoa
import RxSwift
import UIKit

final class SearchViewController: UIViewController, View {
    typealias Reactor = SearchReactor

    var disposeBag = DisposeBag()
    private let searchView = SearchView()
    private var dataSource: UICollectionViewDiffableDataSource<SearchReactor.SearchSectionModel, SearchReactor.SearchItem>?
    private weak var coordinator: HomeCoordinator?

    init(reactor: SearchReactor, coordinator: HomeCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = searchView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        hideKeyboardWhenTappedBackground()
    }

    override func viewWillAppear(_ animated: Bool) {
        reactor?.action.onNext(.viewWillAppear)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchView.searchTextField.becomeFirstResponder()
    }

    func bind(reactor: Reactor) {
        bindAction(to: reactor)
        bindState(from: reactor)
        bindRoute(from: reactor)
    }
}

private extension SearchViewController {
    func bindAction(to reactor: Reactor) {
        searchView.searchTextField.rx.text.orEmpty
            .skip(1)
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .map(Reactor.Action.updateQuery)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        searchView.searchTextField.rx.controlEvent(.editingDidEnd)
            .map { Reactor.Action.endEditingQuery }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        searchView.searchTextField.clearButton.rx.tap
            .map { .clearButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }

    func bindState(from reactor: Reactor) {
        reactor.state
            .map { $0.sections }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .drive { [weak self] sections in
                self?.applySnapshot(sections: sections)
            }
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.shouldShowNoResultsView }
            .distinctUntilChanged()
            .map { !$0 }
            .asDriver(onErrorJustReturn: true)
            .drive(searchView.emptyStateView.rx.isHidden)
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.query }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "")
            .drive(searchView.searchTextField.rx.text)
            .disposed(by: disposeBag)
    }

    func bindRoute(from reactor: Reactor) {
        reactor.pulse(\.$route)
            .compactMap { $0 }
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] route in
                guard let self else { return }
                switch route {
                case .showWebView(let url):
                    coordinator?.showWebView(url: url)
                case .showFolderView(let folder):
                    coordinator?.showFolder(folder: folder)
                case .showEditFolder(let parent, let folder):
                    coordinator?.showEditFolder(parentFolder: parent, folder: folder)
                case .showEditClip(let clip):
                    coordinator?.showEditClip(clip: clip)
                case .showDetailClip(let clip):
                    coordinator?.showDetailClip(clip: clip)
                }
            }
            .disposed(by: disposeBag)
    }
}

private extension SearchViewController {
    func configure() {
        setAttributes()
        setDataSource()
    }

    func setAttributes() {
        searchView.collectionView.delegate = self
        searchView.setCollecrtionViewLayout(layout: createLayout())
    }

    func setDataSource() {
        guard let reactor else { return }

        let recentQueryCellRegistration = UICollectionView.CellRegistration<RecentQueryCell, String> { cell, _, query in
            cell.setDisplay(query)
            cell.deleteButton.rx.tap
                .map { Reactor.Action.deleteRecentQueryTapped(query) }
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)
        }

        let recentVisitedClipCellRegistration = UICollectionView.CellRegistration<RecentVisitedClipCell, ClipDisplay> { cell, _, clipDisplay in
            cell.setDisplay(clipDisplay)
            cell.deleteButton.rx.tap
                .map { Reactor.Action.deleteRecentVisitedClipTapped(clipDisplay) }
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)
        }

        let folderCellRegistration = UICollectionView.CellRegistration<SearchFolderCell, SearchReactor.SearchItem> { cell, _, item in
            if case let .folder(folderDisplay, query) = item {
                cell.setDisplay(folderDisplay, query: query)
            }
        }

        let clipCellRegistration = UICollectionView.CellRegistration<SearchClipCell, SearchReactor.SearchItem> { cell, _, item in
            if case let .clip(clipDisplay, query) = item {
                cell.setDisplay(clipDisplay, query: query)
            }
        }

        dataSource = UICollectionViewDiffableDataSource<SearchReactor.SearchSectionModel, SearchReactor.SearchItem>(
            collectionView: searchView.collectionView
        ) { collectionView, indexPath, item -> UICollectionViewCell? in
            switch item {
            case .recentQuery(let query):
                return collectionView.dequeueConfiguredReusableCell(using: recentQueryCellRegistration, for: indexPath, item: query)
            case .recentVisitedClip(let clipDisplay):
                return collectionView.dequeueConfiguredReusableCell(using: recentVisitedClipCellRegistration, for: indexPath, item: clipDisplay)
            case .folder:
                return collectionView.dequeueConfiguredReusableCell(using: folderCellRegistration, for: indexPath, item: item)

            case .clip:
                return collectionView.dequeueConfiguredReusableCell(using: clipCellRegistration, for: indexPath, item: item)
            }
        }

        let headerRegistration = UICollectionView.SupplementaryRegistration<SearchCollectionHeaderView>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [weak self] (headerView, _, indexPath) in
            guard let self, let reactor = self.reactor else { return }
            guard let section = self.dataSource?.snapshot().sectionIdentifiers[indexPath.section] else { return }

            headerView.setTitle(section.section.title)

            switch section.section {
            case .recentQueries:
                headerView.setDeleteAllButtonVisible(true)
                headerView.setCountLabelVisible(false)
                headerView.deleteAllButton.rx.tap
                    .map { Reactor.Action.deleteAllRecentQueriesTapped }
                    .bind(to: reactor.action)
                    .disposed(by: headerView.disposeBag)
            case .recentVisitedClips:
                headerView.setDeleteAllButtonVisible(true)
                headerView.setCountLabelVisible(false)
                headerView.deleteAllButton.rx.tap
                    .map { Reactor.Action.deleteAllRecentVisitedClipsTapped }
                    .bind(to: reactor.action)
                    .disposed(by: headerView.disposeBag)
            case .folderResults, .clipResults:
                headerView.setDeleteAllButtonVisible(false)
                headerView.setCountLabelVisible(true)
                headerView.countLabel.text = "\(section.items.count)개"
            }
        }

        dataSource?.supplementaryViewProvider = { (view, _, index) in
            view.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: index)
        }
    }

    func applySnapshot(sections: [SearchReactor.SearchSectionModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<SearchReactor.SearchSectionModel, SearchReactor.SearchItem>()
        snapshot.appendSections(sections)
        sections.forEach { sectionModel in
            snapshot.appendItems(sectionModel.items, toSection: sectionModel)
        }
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
}

private extension SearchViewController {
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout(
            sectionProvider: { [weak self] sectionIndex, layoutEnvironment in
                guard let self,
                      let section = self.dataSource?.snapshot().sectionIdentifiers[sectionIndex] else {
                    return nil
                }

                switch section.section {
                case .recentQueries:
                    return self.createQueryLayoutSection()
                default:
                    return self.createTableLayoutSection(with: layoutEnvironment)
                }
            },
            configuration: UICollectionViewCompositionalLayoutConfiguration()
        )
        return layout
    }

    func createQueryLayoutSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .estimated(100),
            heightDimension: .absolute(28)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .estimated(100),
            heightDimension: .absolute(28)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 12, leading: 24, bottom: 32, trailing: 24)
        section.interGroupSpacing = 13
        section.orthogonalScrollingBehavior = .continuous

        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(32)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )

        section.boundarySupplementaryItems = [header]

        return section
    }

    func createTableLayoutSection(with layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.showsSeparators = false
        config.backgroundColor = .clear

        config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self,
                  let item = self.dataSource?.itemIdentifier(for: indexPath),
                  let section = self.dataSource?.snapshot().sectionIdentifier(containingItem: item)?.section
            else {
                return nil
            }

            switch section {
            case .recentQueries, .recentVisitedClips:
                return nil
            default:
                let deleteAction = UIContextualAction(
                    style: .destructive,
                    title: nil,
                ) { _, _, completion in
                    self.presentDeleteAlert(title: item.title) {
                        self.reactor?.action.onNext(.deleteTapped(item))
                    }
                    completion(true)
                }
                deleteAction.image = .trashWhite
                deleteAction.backgroundColor = .red600

                return UISwipeActionsConfiguration(actions: [deleteAction])
            }
        }

        let section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)

        section.contentInsets = .init(top: 8, leading: 24, bottom: 24, trailing: 24)
        section.interGroupSpacing = 8

        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(32)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24)

        section.boundarySupplementaryItems = [header]

        return section
    }
}

extension SearchViewController: UICollectionViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let item = self.dataSource?.itemIdentifier(for: indexPath) else { return }
        self.reactor?.action.onNext(.itemTapped(item))
    }

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let item = self.dataSource?.itemIdentifier(for: indexPath),
              let section = self.dataSource?.snapshot().sectionIdentifier(containingItem: item)?.section
        else {
            return nil
        }

        switch section {
        case .recentQueries, .recentVisitedClips:
            return nil
        default:
            return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { [weak self] _ in
                guard let self else { return UIMenu() }

                let detail = self.makeDetailAction(for: item)
                let edit = self.makeEditAction(for: item)
                let delete = self.makeDeleteAction(for: item)

                switch item {
                case .folder:
                    return UIMenu(title: "", children: [edit, delete])
                case .clip:
                    return UIMenu(title: "", children: [detail, edit, delete])
                default:
                    return UIMenu()
                }
            }
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath,
              let cell = collectionView.cellForItem(at: indexPath) else {
            return nil
        }

        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        parameters.visiblePath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: 12)

        return UITargetedPreview(view: cell, parameters: parameters)
    }
}

private extension SearchViewController {
    func makeEditAction(for item: SearchReactor.SearchItem) -> UIAction {
        .init(title: "편집", image: .pen.withTintColor(.textPrimary)) { [weak self] _ in
            self?.reactor?.action.onNext(.editTapped(item))
        }
    }

    func makeDetailAction(for item: SearchReactor.SearchItem) -> UIAction {
        .init(title: "상세정보", image: .info.withTintColor(.textPrimary)) { [weak self] _ in
            self?.reactor?.action.onNext(.detailTapped(item))
        }
    }

    func makeDeleteAction(for item: SearchReactor.SearchItem) -> UIAction {
        .init(title: "삭제", image: .trashRed, attributes: .destructive) { [weak self] _ in
            self?.presentDeleteAlert(title: item.title) {
                self?.reactor?.action.onNext(.deleteTapped(item))
            }
        }
    }
}
