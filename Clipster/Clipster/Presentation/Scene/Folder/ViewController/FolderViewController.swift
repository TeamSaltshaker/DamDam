import RxCocoa
import RxSwift
import SafariServices
import SnapKit
import UIKit

final class FolderViewController: UIViewController {
    private let viewModel: FolderViewModel
    private let diContainer: DIContainer
    private let disposeBag = DisposeBag()

    private let folderView = FolderView()

    init(viewModel: FolderViewModel, diContainer: DIContainer) {
        self.viewModel = viewModel
        self.diContainer = diContainer
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

//    private func makeAddButtonMenu() -> UIMenu {
//        let addFolderAction = UIAction(
//            title: "폴더 추가",
//            image: UIImage(systemName: "folder"),
//        ) { [weak self] _ in
//            guard let self else { return }
//            viewModel.action.accept(.didTapAddFolderButton)
//        }
//        let addClipAction = UIAction(
//            title: "클립 추가",
//            image: UIImage(systemName: "paperclip"),
//        ) { [weak self] _ in
//            guard let self else { return }
//            viewModel.action.accept(.didTapAddClipButton)
//        }
//
//        return UIMenu(title: "", children: [addFolderAction, addClipAction])
//    }
}

private extension FolderViewController {
    func configure() {
//        setNavigationBarItems()
        setBindings()
    }

//    func setNavigationBarItems() {
//        let addButton = UIBarButtonItem(
//            systemItem: .add,
//            menu: makeAddButtonMenu()
//        )
//
//        navigationController?.navigationBar.tintColor = .label
//        navigationItem.rightBarButtonItem = addButton
//    }

    func setBindings() {
        viewModel.state
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] state in
                guard let self else { return }
                folderView.navigationView.setTitle(state.currentFolderTitle)
                folderView.setDisplay(folders: state.folders, clips: state.clips)
            }
            .disposed(by: disposeBag)

        viewModel.navigation
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] navigation in
                guard let self else { return }
                switch navigation {
                case .editClipView(let clip):
                    let vm: EditClipViewModel
                    if let clip = clip {
                        vm = diContainer.makeEditClipViewModel(clip: clip)
                    } else {
                        vm = diContainer.makeEditClipViewModel()
                    }
                    let vc = EditClipViewController(viewModel: vm, diContainer: diContainer)
                    navigationController?.pushViewController(vc, animated: true)
                case .editFolderView(let parentFolder, let folder):
                    let mode: EditFolderMode
                    if let folder = folder {
                        mode = .edit(parentFolder: parentFolder, folder: folder)
                    } else {
                        mode = .add(parentFolder: parentFolder)
                    }
                    let vm = diContainer.makeEditFolderViewModel(mode: mode)
                    let vc = EditFolderViewController(viewModel: vm, diContainer: diContainer)
                    navigationController?.pushViewController(vc, animated: true)
                case .folderView(let folder):
                    let vm = diContainer.makeFolderViewModel(folder: folder)
                    let vc = FolderViewController(viewModel: vm, diContainer: diContainer)
                    navigationController?.pushViewController(vc, animated: true)
                case .clipDetailView(let clip):
                    let vm = diContainer.makeClipDetailViewModel(clip: clip)
                    let vc = ClipDetailViewController(viewModel: vm, diContainer: diContainer)
                    navigationController?.pushViewController(vc, animated: true)
                case .webView(let url):
                    let vc = SFSafariViewController(url: url)
                    present(vc, animated: true)
                }
            }
            .disposed(by: disposeBag)

        folderView.didTapCell
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] indexPath in
                guard let self else { return }
                viewModel.action.accept(.didTapCell(indexPath))
            }
            .disposed(by: disposeBag)

        folderView.didTapDetailButton
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] indexPath in
                guard let self else { return }
                viewModel.action.accept(.didTapDetailButton(indexPath))
            }
            .disposed(by: disposeBag)

        folderView.didTapEditButton
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] indexPath in
                guard let self else { return }
                viewModel.action.accept(.didTapEditButton(indexPath))
            }
            .disposed(by: disposeBag)

        folderView.didTapDeleteButton
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] (indexPath, title) in
                guard let self else { return }

                let alertController = UIAlertController(
                    title: title,
                    message: "삭제하겠습니까?",
                    preferredStyle: .alert,
                )

                let cancelAction = UIAlertAction(title: "취소", style: .cancel)
                alertController.addAction(cancelAction)

                let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { _ in
                    self.viewModel.action.accept(.didTapDeleteButton(indexPath))
                }
                alertController.addAction(deleteAction)

                self.present(alertController, animated: true)
            }
            .disposed(by: disposeBag)
    }
}
