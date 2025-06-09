import RxSwift
import UIKit

final class FolderSelectorViewController: UIViewController {
    private let viewModel: FolderSelectorViewModel
    private let disposeBag = DisposeBag()

    private let folderSelectorView = FolderSelectorView()

    var onSelectionComplete: ((Folder?) -> Void)?

    init(viewModel: FolderSelectorViewModel) {
        self.viewModel = viewModel
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
}

private extension FolderSelectorViewController {
    func configure() {
        setBindings()
    }

    func setBindings() {
        let navigationView = folderSelectorView.folderSelectorNavigationView
        let tableView = folderSelectorView.tableView
        let state = viewModel.state.share(replay: 1)

        navigationView.backButtonTap
            .map { .navigateUp }
            .bind(to: viewModel.action)
            .disposed(by: disposeBag)

        navigationView.selectButtonTap
            .map { .selectButtonTapped }
            .bind(to: viewModel.action)
            .disposed(by: disposeBag)

        tableView.rx.modelSelected(Folder.self)
            .map { .openSubfolder(folder: $0) }
            .bind(to: viewModel.action)
            .disposed(by: disposeBag)

        state
            .map(\.subfolders)
            .bind(to: tableView.rx.items(cellIdentifier: FolderSelectorCell.identifier, cellType: FolderSelectorCell.self)) { _, folder, cell in
                cell.setDisplay(FolderDisplayMapper.map(folder))
            }
            .disposed(by: disposeBag)

        state
            .map(\.title)
            .bind(to: navigationView.titleLabel.rx.text)
            .disposed(by: disposeBag)

        state
            .map { !$0.canNavigateUp }
            .bind(to: navigationView.backButton.rx.isHidden)
            .disposed(by: disposeBag)

        state
            .compactMap(\.didFinishSelection)
            .take(1)
            .subscribe { [weak self] selectedFolder in
                self?.dismiss(animated: true) {
                    self?.onSelectionComplete?(selectedFolder)
                }
            }
            .disposed(by: disposeBag)
    }
}
