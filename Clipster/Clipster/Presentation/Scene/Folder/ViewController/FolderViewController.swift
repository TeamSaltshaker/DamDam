import RxCocoa
import RxSwift
import SafariServices
import SnapKit
import UIKit

final class FolderViewController: UIViewController {
    private let viewModel: FolderViewModel
    private let disposeBag = DisposeBag()

    private let folderView = FolderView()

    init(viewModel: FolderViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = folderView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    private func makeAddButtonMenu() -> UIMenu {
        let addFolderAction = UIAction(
            title: "폴더 추가",
            image: UIImage(systemName: "folder"),
        ) { [weak self] _ in
            guard let self else { return }
            viewModel.action.accept(.didTapAddFolderButton)
        }
        let addClipAction = UIAction(
            title: "클립 추가",
            image: UIImage(systemName: "paperclip"),
        ) { [weak self] _ in
            guard let self else { return }
            viewModel.action.accept(.didTapAddClipButton)
        }

        return UIMenu(title: "", children: [addFolderAction, addClipAction])
    }
}

private extension FolderViewController {
    func configure() {
        setNavigationBarItems()
        setBindings()
    }

    func setNavigationBarItems() {
        let addButton = UIBarButtonItem(
            systemItem: .add,
            menu: makeAddButtonMenu()
        )

        navigationController?.navigationBar.tintColor = .label
        navigationItem.rightBarButtonItem = addButton
    }

    func setBindings() {
        viewModel.state
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] state in
                guard let self else { return }
                title = state.currentFolderTitle
                folderView.setDisplay(folders: state.folders, clips: state.clips)
            }
            .disposed(by: disposeBag)

        viewModel.navigation
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] navigation in
                guard let self else { return }
                switch navigation {
                case .editClipView(let clip):
                    let urlValidationReposiotry = DefaultURLValidationRepository()
                    let checkValidityUC = DefaultCheckVaildityUseCase(repository: urlValidationReposiotry)
                    let urlMetadataRepository = DefaultURLMetadataRepository()
                    let parseURLMetadataUC = DefaultParseURLMetadataUseCase(repository: urlMetadataRepository)
                    let editClipVM: EditClipViewModel
                    if let clip = clip {
                        editClipVM = EditClipViewModel(
                            clip: clip,
                            checkURLValidityUseCase: checkValidityUC,
                            parseURLMetadataUseCase: parseURLMetadataUC,
                        )
                    } else {
                        editClipVM = EditClipViewModel(
                            checkURLValidityUseCase: checkValidityUC,
                            parseURLMetadataUseCase: parseURLMetadataUC,
                        )
                    }
                    let editClipVC = EditClipViewController(viewModel: editClipVM)
                    navigationController?.pushViewController(editClipVC, animated: true)
                case .editFolderView(let parentFolder, let folder):
                    let folderStorage = DefaultFolderStorage(context: CoreDataStack.shared.context)
                    let folderRepository = DefaultFolderRepository(
                        storage: folderStorage,
                        mapper: DomainMapper(),
                    )
                    let createFolderUC = DefaultCreateFolderUseCase(folderRepository: folderRepository)
                    let updateFolderUC = DefaultUpdateFolderUseCase(folderRepository: folderRepository)
                    let mode: EditFolderMode
                    if let folder = folder {
                        mode = .edit(parentFolder: parentFolder, folder: folder)
                    } else {
                        mode = .add(parentFolder: parentFolder)
                    }
                    let editFolderVM = EditFolderViewModel(
                        createFolderUseCase: createFolderUC,
                        updateFolderUseCase: updateFolderUC,
                        mode: mode,
                    )
                    let editFolderVC = EditFolderViewController(viewModel: editFolderVM)
                    navigationController?.pushViewController(editFolderVC, animated: true)
                case .folderView(let folder):
                    let clipStorage = DefaultClipStorage(context: CoreDataStack.shared.context)
                    let clipRepository = DefaultClipRepository(storage: clipStorage, mapper: DomainMapper())
                    let deleteClipUC = DefaultDeleteClipUseCase(clipRepository: clipRepository)
                    let childFolderVM = FolderViewModel(
                        folder: folder,
                        mapper: CellDisplayMapper(),
                        deleteFolderUseCase: DefaultDeleteFolderUseCase(),
                        deleteClipUseCase: deleteClipUC,
                    )
                    let childFolderVC = FolderViewController(viewModel: childFolderVM)
                    navigationController?.pushViewController(childFolderVC, animated: true)
                case .clipDetailView(let clip):
                    () // TODO: clipDetailView
                case .webView(let url):
                    let safariVC = SFSafariViewController(url: url)
                    present(safariVC, animated: true)
                }
            }
            .disposed(by: disposeBag)

        folderView.collectionView
            .rx
            .itemSelected
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] indexPath in
                guard let self else { return }
                viewModel.action.accept(.didTapCell(indexPath))
            }
            .disposed(by: disposeBag)
    }
}
