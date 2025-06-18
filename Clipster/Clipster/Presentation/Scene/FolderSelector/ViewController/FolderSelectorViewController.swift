import ReactorKit
import RxSwift
import UIKit

final class FolderSelectorViewController: UIViewController, View {
    typealias Reactor = FolderSelectorReactor
    private let diContainer: DIContainer
    var disposeBag = DisposeBag()

    private let folderSelectorView = FolderSelectorView()

    var onSelectionComplete: ((Folder?) -> Void)?
    var onDismissed: (() -> Void)?

    init(reactor: Reactor, diContainer: DIContainer) {
        self.diContainer = diContainer
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = folderSelectorView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        reactor?.action.onNext(.viewDidLoad)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        onDismissed?()
    }

    func bind(reactor: Reactor) {
        bindAction(to: reactor)
        bindState(from: reactor)
    }
}

private extension FolderSelectorViewController {
    func bindAction(to reactor: Reactor) {
        folderSelectorView.backButton.rx.tap
            .map { .navigateUp }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        folderSelectorView.selectButton.rx.tap
            .map { .selectButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        folderSelectorView.tableView.rx.modelSelected(Folder.self)
            .map { .navigateTo($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }

    func bindState(from reactor: Reactor) {
        reactor.state
            .map(\.filteredSubfolders)
            .observe(on: MainScheduler.instance)
            .bind(
                to: folderSelectorView.tableView.rx.items(
                    cellIdentifier: FolderSelectorCell.identifier,
                    cellType: FolderSelectorCell.self
                )
            ) { _, folder, cell in
                cell.setDisplay(FolderDisplayMapper.map(folder))
            }
            .disposed(by: disposeBag)

        reactor.state
            .map(\.title)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind { [weak self] title in
                self?.folderSelectorView.commonNavigationView.setTitle(title)
            }
            .disposed(by: disposeBag)

        reactor.state
            .map { !$0.canNavigateUp }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: folderSelectorView.backButton.rx.isHidden)
            .disposed(by: disposeBag)

        reactor.state
            .map(\.isSelectable)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: folderSelectorView.selectButton.rx.isEnabled)
            .disposed(by: disposeBag)

        reactor.pulse(\.$phase)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] phase in
                guard let self = self else { return }
                switch phase {
                case .idle:
                    break
                case .loading:
                    break
                case .success(let selectedFolder):
                    self.onSelectionComplete?(selectedFolder)
                    self.dismiss(animated: true)
                case .error:
                    break
                }
            }
            .disposed(by: disposeBag)
    }
}
