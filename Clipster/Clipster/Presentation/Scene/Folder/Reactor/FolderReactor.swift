import Foundation
import ReactorKit
import RxRelay

final class FolderReactor: Reactor {
    enum Action {
        case viewWillAppear
        case didTapCell(IndexPath)
        case didTapAddFolderButton
        case didTapAddClipButton
        case didTapDetailButton(IndexPath)
        case didTapEditButton(IndexPath)
        case didTapDeleteButton(IndexPath)
    }

    enum Mutation {
        case reloadFolder(Folder)
        case updateClipLastVisitedDate(Clip)
        case delete
        case setRoute(Route)
    }

    struct State {
        var currentFolderTitle: String
        var folders: [FolderDisplay]
        var clips: [ClipDisplay]
        var isEmptyViewHidden: Bool
        @Pulse var route: Route?
    }

    enum Route {
        case editClipViewForAdd(Folder)
        case editClipViewForEdit(Clip)
        case editFolderView(Folder, Folder?)
        case folderView(Folder)
        case clipDetailView(Clip)
        case webView(URL)
    }

    let initialState: State
    private var folder: Folder
    private var isFirstAppear = true

    private let fetchFolderUseCase: FetchFolderUseCase
    private let deleteFolderUseCase: DeleteFolderUseCase
    private let updateClipUseCase: UpdateClipUseCase
    private let deleteClipUseCase: DeleteClipUseCase

    init(
        folder: Folder,
        fetchFolderUseCase: FetchFolderUseCase,
        deleteFolderUseCase: DeleteFolderUseCase,
        updateClipUseCase: UpdateClipUseCase,
        deleteClipUseCase: DeleteClipUseCase,
    ) {
        self.folder = folder
        self.fetchFolderUseCase = fetchFolderUseCase
        self.deleteFolderUseCase = deleteFolderUseCase
        self.updateClipUseCase = updateClipUseCase
        self.deleteClipUseCase = deleteClipUseCase

        initialState = State(
            currentFolderTitle: folder.title,
            folders: folder.folders.map { FolderDisplayMapper.map($0) },
            clips: folder.clips.map { ClipDisplayMapper.map($0) },
            isEmptyViewHidden: !folder.folders.isEmpty || !folder.clips.isEmpty,
        )
    }

    func mutate(action: Action) -> Observable<Mutation> {
        print("\(Self.self): action → \(action)")

        switch action {
        case .viewWillAppear:
            if isFirstAppear {
                isFirstAppear = false
                return .empty()
            }
            return .fromAsync { [weak self] in
                guard let self else { throw DomainError.unknownError }
                return try await fetchFolderUseCase.execute(id: folder.id).get()
            }
            .map { .reloadFolder($0) }
            .catch { _ in .empty() }
        case .didTapCell(let indexPath):
            switch indexPath.section {
            case 0:
                let folder = folder.folders[indexPath.item]
                return .just(.setRoute(.folderView(folder)))
            case 1:
                let url = folder.clips[indexPath.item].urlMetadata.url
                return .concat(
                    .fromAsync { [weak self] in
                        guard let self else { throw DomainError.unknownError }
                        let clip = folder.clips[indexPath.item]
                        let updatedClip = Clip(
                            id: clip.id,
                            folderID: clip.folderID,
                            urlMetadata: clip.urlMetadata,
                            memo: clip.memo,
                            lastVisitedAt: Date.now,
                            createdAt: clip.createdAt,
                            updatedAt: Date.now,
                            deletedAt: clip.deletedAt,
                        )
                        _ = await updateClipUseCase.execute(clip: updatedClip)
                        return updatedClip
                    }
                    .map { .updateClipLastVisitedDate($0) }
                    .catch { _ in .empty() },
                    .just(.setRoute(.webView(url)))
                )
            default:
                return .empty()
            }
        case .didTapAddFolderButton:
            return .just(.setRoute(.editFolderView(folder, nil)))
        case .didTapAddClipButton:
            return .just(.setRoute(.editClipViewForAdd(folder)))
        case .didTapDetailButton(let indexPath):
            switch indexPath.section {
            case 1:
                let clip = folder.clips[indexPath.item]
                return .just(.setRoute(.clipDetailView(clip)))
            default:
                return .empty()
            }
        case .didTapEditButton(let indexPath):
            switch indexPath.section {
            case 0:
                let selectedFolder = folder.folders[indexPath.item]
                return .just(.setRoute(.editFolderView(folder, selectedFolder)))
            case 1:
                let clip = folder.clips[indexPath.item]
                return .just(.setRoute(.editClipViewForEdit(clip)))
            default:
                return .empty()
            }
        case .didTapDeleteButton(let indexPath):
            return .concat(
                .fromAsync { [weak self] in
                    guard let self else { throw DomainError.unknownError }
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
                    return .delete
                },
                .fromAsync { [weak self] in
                    guard let self else { throw DomainError.unknownError }
                    return try await fetchFolderUseCase.execute(id: folder.id).get()
                }
                .map { .reloadFolder($0) }
                .catch { _ in .empty() },
            )
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case .reloadFolder(let folder):
            self.folder = folder
            newState.currentFolderTitle = folder.title
            newState.folders = folder.folders.map(FolderDisplayMapper.map)
            newState.clips = folder.clips.map(ClipDisplayMapper.map)
            newState.isEmptyViewHidden = !folder.folders.isEmpty || !folder.clips.isEmpty
        case .updateClipLastVisitedDate(let updatedClip):
            if let index = newState.clips.firstIndex(where: { $0.id == updatedClip.id }) {
                newState.clips[index] = ClipDisplayMapper.map(updatedClip)
            }
        case .delete:
            break
        case .setRoute(let route):
            newState.route = route
        }

        return newState
    }
}
