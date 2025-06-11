import Foundation
import RxRelay
import RxSwift

final class FolderViewModel {
    enum Action {
        case viewWillAppear
        case didTapCell(IndexPath)
        case didTapAddFolderButton
        case didTapAddClipButton
        case didTapDetailButton(IndexPath)
        case didTapEditButton(IndexPath)
        case didTapDeleteButton(IndexPath)
    }

    struct State {
        let currentFolderTitle: String
        let folders: [FolderDisplay]
        let clips: [ClipDisplay]
    }

    enum Navigation {
        case editClipView(Clip?)
        case editFolderView(Folder, Folder?)
        case folderView(Folder)
        case clipDetailView(Clip)
        case webView(URL)
    }

    var action = PublishRelay<Action>()
    var state: BehaviorRelay<State>
    var navigation = PublishRelay<Navigation>()
    var disposeBag = DisposeBag()

    private var folder: Folder
    private let fetchFolderUseCase: FetchFolderUseCase
    private let deleteFolderUseCase: DeleteFolderUseCase
    private let deleteClipUseCase: DeleteClipUseCase

    init(
        folder: Folder,
        fetchFolderUseCase: FetchFolderUseCase,
        deleteFolderUseCase: DeleteFolderUseCase,
        deleteClipUseCase: DeleteClipUseCase,
    ) {
        self.folder = folder
        self.fetchFolderUseCase = fetchFolderUseCase
        self.deleteFolderUseCase = deleteFolderUseCase
        self.deleteClipUseCase = deleteClipUseCase

        state = BehaviorRelay(value: State(
            currentFolderTitle: folder.title,
            folders: folder.folders.map { FolderDisplayMapper.map($0) },
            clips: folder.clips.map { ClipDisplayMapper.map($0) },
        ))
        setBindings()
    }
}

private extension FolderViewModel {
    func setBindings() {
        action
            .skip(1)
            .subscribe { [weak self] action in
                guard let self else { return }
                print("\(Self.self): \(action)")

                switch action {
                case .viewWillAppear:
                    reloadFolder()
                case .didTapCell(let indexPath):
                    switch indexPath.section {
                    case 0:
                        navigateToFolderView(at: indexPath.item)
                    case 1:
                        navigateToWebView(at: indexPath.item)
                    default:
                        break
                    }
                case .didTapAddClipButton:
                    navigateToAddClipView()
                case .didTapAddFolderButton:
                    navigateToAddFolderView()
                case .didTapDetailButton(let indexPath):
                    navigateToDetailView(at: indexPath)
                case .didTapEditButton(let indexPath):
                    navigateToEditView(at: indexPath)
                case .didTapDeleteButton(let indexPath):
                    delete(at: indexPath)
                }
            }
            .disposed(by: disposeBag)
    }

    func reloadFolder() {
        print("\(Self.self): reloadFolder() called")
        Task {
            guard case let .success(folder) = await fetchFolderUseCase.execute(id: folder.id) else {
                print("\(Self.self): Failed to reload")
                return
            }

            self.folder = folder
            state.accept(.init(
                currentFolderTitle: folder.title,
                folders: folder.folders.map(FolderDisplayMapper.map),
                clips: folder.clips.map(ClipDisplayMapper.map)
            ))
        }
    }

    func navigateToWebView(at index: Int) {
        let url = folder.clips[index].urlMetadata.url
        navigation.accept(.webView(url))
    }

    func navigateToFolderView(at index: Int) {
        let folder = folder.folders[index]
        navigation.accept(.folderView(folder))
    }

    func navigateToAddClipView() {
        navigation.accept(.editClipView(nil))
    }

    func navigateToAddFolderView() {
        navigation.accept(.editFolderView(folder, nil))
    }

    func navigateToDetailView(at indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            let selectedClip = folder.clips[indexPath.item]
            navigation.accept(.clipDetailView(selectedClip))
        default:
            break
        }
    }

    func navigateToEditView(at indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let selectedFolder = folder.folders[indexPath.item]
            navigation.accept(.editFolderView(folder, selectedFolder))
        case 1:
            let selectedClip = folder.clips[indexPath.item]
            navigation.accept(.editClipView(selectedClip))
        default:
            break
        }
    }

    func delete(at indexPath: IndexPath) {
        Task {
            switch indexPath.section {
            case 0:
                let folder = folder.folders[indexPath.item]
                _ = await deleteFolderUseCase.execute(folder)
            case 1:
                let clip = folder.clips[indexPath.item]
                _ = await deleteClipUseCase.execute(clip)
            default:
                break
            }
            reloadFolder()
        }
    }
}
