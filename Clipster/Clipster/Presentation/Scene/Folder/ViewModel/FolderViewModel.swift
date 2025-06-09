import Foundation
import RxRelay
import RxSwift

final class FolderViewModel {
    enum Action {
        case didTapCell(IndexPath)
        case didTapAddFolderButton
        case didTapAddClipButton
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
        case editFolderView(Folder?)
        case folderView(Folder)
        case clipDetailView(Clip)
        case webView(URL)
    }

    var action = PublishRelay<Action>()
    var state: BehaviorRelay<State>
    var navigation = PublishRelay<Navigation>()
    var disposeBag = DisposeBag()

    private let folder: Folder
    private let deleteFolderUseCase: DeleteFolderUseCase
    private let deleteClipUseCase: DeleteClipUseCase

    init(
        folder: Folder,
        deleteFolderUseCase: DeleteFolderUseCase,
        deleteClipUseCase: DeleteClipUseCase,
    ) {
        self.folder = folder
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
            .subscribe { [weak self] action in
                guard let self else { return }
                print("\(Self.self): \(action)")

                switch action {
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
                case .didTapEditButton(let indexPath):
                    navigateToEditView(at: indexPath)
                case .didTapDeleteButton(let indexPath):
                    delete(at: indexPath)
                }
            }
            .disposed(by: disposeBag)
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
        navigation.accept(.editFolderView(nil))
    }

    func navigateToEditView(at indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let folder = folder.folders[indexPath.item]
            navigation.accept(.editFolderView(folder))
        case 1:
            let clip = folder.clips[indexPath.item]
            navigation.accept(.editClipView(clip))
        default:
            break
        }
    }

    func delete(at indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            Task {
                let folder = folder.folders[indexPath.item]
                _ = await deleteFolderUseCase.execute(folder)
            }
        case 1:
            Task {
                let clip = folder.clips[indexPath.item]
                _ = await deleteClipUseCase.execute(clip)
            }
        default:
            break
        }
    }
}
