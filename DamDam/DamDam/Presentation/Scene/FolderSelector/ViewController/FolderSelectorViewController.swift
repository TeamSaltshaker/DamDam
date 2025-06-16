import RxSwift
import UIKit

final class FolderSelectorViewController: UIViewController {
    private let viewModel: FolderSelectorViewModel
    private let diContainer: DIContainer
    private let disposeBag = DisposeBag()

    private let folderSelectorView = FolderSelectorView()

    var onSelectionComplete: ((Folder?) -> Void)?
    var onDismissed: (() -> Void)?

    init(viewModel: FolderSelectorViewModel, diContainer: DIContainer) {
        self.viewModel = viewModel
        self.diContainer = diContainer
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = folderSelectorView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        viewModel.action.accept(.viewDidLoad)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        onDismissed?()
    }
}

private extension FolderSelectorViewController {
    func configure() {
        setBindings()
    }

    func setBindings() {
        let tableView = folderSelectorView.tableView
        let state = viewModel.state.share(replay: 1)

        folderSelectorView.backButton.rx.tap
            .map { .navigateUp }
            .bind(to: viewModel.action)
            .disposed(by: disposeBag)

        folderSelectorView.selectButton.rx.tap
            .map { .selectButtonTapped }
            .bind(to: viewModel.action)
            .disposed(by: disposeBag)

        tableView.rx.modelSelected(Folder.self)
            .map { .openSubfolder(folder: $0) }
            .bind(to: viewModel.action)
            .disposed(by: disposeBag)

        state
            .map(\.subfolders)
            .bind(
                to: tableView.rx.items(
                    cellIdentifier: FolderSelectorCell.identifier,
                    cellType: FolderSelectorCell.self
                )
            ) { _, folder, cell in
                cell.setDisplay(FolderDisplayMapper.map(folder))
            }
            .disposed(by: disposeBag)

        state
            .map(\.title)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] title in
                self?.folderSelectorView.commonNavigationView.setTitle(title)
            }
            .disposed(by: disposeBag)

        state
            .map { !$0.canNavigateUp }
            .bind(to: folderSelectorView.backButton.rx.isHidden)
            .disposed(by: disposeBag)

        state
            .map(\.shouldDismiss)
            .distinctUntilChanged()
            .filter { $0 }
            .take(1)
            .withLatestFrom(state)
            .subscribe { [weak self] state in
                guard let self else { return }

                self.onSelectionComplete?(state.didFinishSelection)
                self.dismiss(animated: true)
            }
            .disposed(by: disposeBag)

        state
            .map { $0.isSelectable }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: folderSelectorView.selectButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
}
