import Foundation
import ReactorKit

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
        case setPhase(Phase)
        case setRoute(Route)
    }

    struct State {
        var currentFolderTitle: String
        var folders: [FolderDisplay]
        var clips: [ClipDisplay]
        var isEmptyViewHidden: Bool

        @Pulse var phase: Phase
        @Pulse var route: Route?
    }

    enum Phase {
        case idle
        case loading
        case success
        case error(String)
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
    private let visitClipUseCase: VisitClipUseCase
    private let deleteClipUseCase: DeleteClipUseCase

    init(
        folder: Folder,
        fetchFolderUseCase: FetchFolderUseCase,
        deleteFolderUseCase: DeleteFolderUseCase,
        visitClipUseCase: VisitClipUseCase,
        deleteClipUseCase: DeleteClipUseCase,
    ) {
        self.folder = folder
        self.fetchFolderUseCase = fetchFolderUseCase
        self.deleteFolderUseCase = deleteFolderUseCase
        self.visitClipUseCase = visitClipUseCase
        self.deleteClipUseCase = deleteClipUseCase

        initialState = State(
            currentFolderTitle: folder.title,
            folders: folder.folders.map { FolderDisplayMapper.map($0) },
            clips: folder.clips.map { ClipDisplayMapper.map($0) },
            isEmptyViewHidden: !folder.folders.isEmpty || !folder.clips.isEmpty,
            phase: .idle,
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

            return .concat(
                .just(.setPhase(.loading)),
                .fromAsync { [weak self] in
                    guard let self else {
                        let message = DomainError.unknownError.localizedDescription
                        return .setPhase(.error(message))
                    }

                    let result = await fetchFolderUseCase.execute(id: folder.id)
                    switch result {
                    case .success(let folder):
                        return .reloadFolder(folder)
                    case .failure(let error):
                        return .setPhase(.error(error.localizedDescription))
                    }
                },
                .just(.setPhase(.idle)),
            )
        case .didTapCell(let indexPath):
            switch indexPath.section {
            case 0:
                let folder = folder.folders[indexPath.item]
                return .just(.setRoute(.folderView(folder)))
            case 1:
                let clip = folder.clips[indexPath.item]
                return .concat(
                    .just(.setPhase(.loading)),
                    .fromAsync { [weak self] in
                        guard let self else {
                            let message = DomainError.unknownError.localizedDescription
                            return .setPhase(.error(message))
                        }

                        let result = await visitClipUseCase.execute(clip: clip)
                        switch result {
                        case .success:
                            return .updateClipLastVisitedDate(clip)
                        case .failure(let error):
                            return .setPhase(.error(error.localizedDescription))
                        }
                    },
                    .just(.setRoute(.webView(clip.url))),
                    .just(.setPhase(.idle)),
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
                .just(.setPhase(.loading)),
                .fromAsync { [weak self] in
                    guard let self else {
                        let message = DomainError.unknownError.localizedDescription
                        return .setPhase(.error(message))
                    }

                    switch indexPath.section {
                    case 0:
                        let folder = folder.folders[indexPath.item]
                        let result = await deleteFolderUseCase.execute(folder)
                        if case .failure(let error) = result {
                            return .setPhase(.error(error.localizedDescription))
                        }
                    case 1:
                        let clip = folder.clips[indexPath.item]
                        let result = await deleteClipUseCase.execute(clip)
                        if case .failure(let error) = result {
                            return .setPhase(.error(error.localizedDescription))
                        }
                    default:
                        return .setPhase(.error("Invalid section index"))
                    }

                    return .setPhase(.success)
                },
                .just(.setPhase(.loading)),
                .fromAsync { [weak self] in
                    guard let self else {
                        let message = DomainError.unknownError.localizedDescription
                        return .setPhase(.error(message))
                    }

                    let result = await fetchFolderUseCase.execute(id: folder.id)
                    switch result {
                    case .success(let folder):
                        return .reloadFolder(folder)
                    case .failure(let error):
                        return .setPhase(.error(error.localizedDescription))
                    }
                },
                .just(.setPhase(.idle)),
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
        case .setPhase(let phase):
            newState.phase = phase
        case .setRoute(let route):
            newState.route = route
        }

        return newState
    }
}
