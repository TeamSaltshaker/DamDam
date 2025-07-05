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
        case fetchFolder(Folder)
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

    enum SectionType {
        case folder(Folder)
        case clip(Clip)
    }

    let initialState: State
    private var folder: Folder

    private let fetchFolderUseCase: FetchFolderUseCase
    private let fetchFolderSortOptionUseCase: FetchFolderSortOptionUseCase
    private let fetchClipSortOptionUseCase: FetchClipSortOptionUseCase
    private let sortFoldersUseCase: SortFoldersUseCase
    private let sortClipsUseCase: SortClipsUseCase
    private let deleteFolderUseCase: DeleteFolderUseCase
    private let visitClipUseCase: VisitClipUseCase
    private let deleteClipUseCase: DeleteClipUseCase

    init(
        folder: Folder,
        fetchFolderUseCase: FetchFolderUseCase,
        fetchFolderSortOptionUseCase: FetchFolderSortOptionUseCase,
        fetchClipSortOptionUseCase: FetchClipSortOptionUseCase,
        sortFoldersUseCase: SortFoldersUseCase,
        sortClipsUseCase: SortClipsUseCase,
        deleteFolderUseCase: DeleteFolderUseCase,
        visitClipUseCase: VisitClipUseCase,
        deleteClipUseCase: DeleteClipUseCase,
    ) {
        self.folder = folder
        self.fetchFolderUseCase = fetchFolderUseCase
        self.fetchFolderSortOptionUseCase = fetchFolderSortOptionUseCase
        self.fetchClipSortOptionUseCase = fetchClipSortOptionUseCase
        self.sortFoldersUseCase = sortFoldersUseCase
        self.sortClipsUseCase = sortClipsUseCase
        self.deleteFolderUseCase = deleteFolderUseCase
        self.visitClipUseCase = visitClipUseCase
        self.deleteClipUseCase = deleteClipUseCase

        initialState = State(
            currentFolderTitle: "",
            folders: [],
            clips: [],
            isEmptyViewHidden: true,
            phase: .idle,
        )
    }

    func mutate(action: Action) -> Observable<Mutation> {
        print("\(Self.self): action → \(action)")

        switch action {
        case .viewWillAppear:
            return .concat(
                .just(.setPhase(.loading)),
                fetchFolderMutation(),
                .just(.setPhase(.success)),
            )
        case .didTapCell(let indexPath):
            guard let section = section(at: indexPath) else {
                return .just(.setPhase(.error("Invalid section")))
            }
            switch section {
            case .folder(let folder):
                return .just(.setRoute(.folderView(folder)))
            case .clip(let clip):
                return .concat(
                    .just(.setPhase(.loading)),
                    visitClipMutation(clip),
                    .just(.setRoute(.webView(clip.url))),
                )
            }
        case .didTapAddFolderButton:
            return .just(.setRoute(.editFolderView(folder, nil)))
        case .didTapAddClipButton:
            return .just(.setRoute(.editClipViewForAdd(folder)))
        case .didTapDetailButton(let indexPath):
            guard let section = section(at: indexPath) else {
                return .just(.setPhase(.error("Invalid section")))
            }
            switch section {
            case .folder:
                return .empty()
            case .clip(let clip):
                return .just(.setRoute(.clipDetailView(clip)))
            }
        case .didTapEditButton(let indexPath):
            guard let section = section(at: indexPath) else {
                return .just(.setPhase(.error("Invalid section")))
            }
            switch section {
            case .folder(let selectedFolder):
                return .just(.setRoute(.editFolderView(folder, selectedFolder)))
            case .clip(let clip):
                return .just(.setRoute(.editClipViewForEdit(clip)))
            }
        case .didTapDeleteButton(let indexPath):
            return .concat(
                .just(.setPhase(.loading)),
                deleteMutation(at: indexPath),
                fetchFolderMutation(),
            )
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case .fetchFolder(let folder):
            self.folder = folder
            newState.currentFolderTitle = folder.title
            newState.folders = folder.folders.map(FolderDisplayMapper.map)
            newState.clips = folder.clips.map(ClipDisplayMapper.map)
            newState.isEmptyViewHidden = !folder.folders.isEmpty || !folder.clips.isEmpty
        case .setPhase(let phase):
            newState.phase = phase
        case .setRoute(let route):
            newState.route = route
        }

        return newState
    }
}

private extension FolderReactor {
    func fetchFolderMutation() -> Observable<Mutation> {
        .fromAsync { [weak self] in
            guard let self else {
                let message = DomainError.unknownError.localizedDescription
                return .setPhase(.error(message))
            }
            let folder = try await fetchFolderUseCase.execute(id: folder.id).get()
            let folderSortOption = try await fetchFolderSortOptionUseCase.execute().get()
            let clipSortOption = try await fetchClipSortOptionUseCase.execute().get()
            let sortedFolder = Folder(
                id: folder.id,
                parentFolderID: folder.parentFolderID,
                title: folder.title,
                depth: folder.depth,
                folders: sortFoldersUseCase.execute(folder.folders, by: folderSortOption),
                clips: sortClipsUseCase.execute(folder.clips, by: clipSortOption),
                createdAt: folder.createdAt,
                updatedAt: folder.updatedAt,
                deletedAt: folder.deletedAt,
            )
            return .fetchFolder(sortedFolder)
        }
        .catch { error in
            .just(.setPhase(.error(error.localizedDescription)))
        }
    }

    func visitClipMutation(_ clip: Clip) -> Observable<Mutation> {
        .fromAsync { [weak self] in
            guard let self else {
                let message = DomainError.unknownError.localizedDescription
                return .setPhase(.error(message))
            }
            _ = try await visitClipUseCase.execute(clip: clip).get()
            return .setPhase(.success)
        }
        .catch { error in
            .just(.setPhase(.error(error.localizedDescription)))
        }
    }

    func deleteMutation(at indexPath: IndexPath) -> Observable<Mutation> {
        .fromAsync { [weak self] in
            guard let self else {
                let message = DomainError.unknownError.localizedDescription
                return .setPhase(.error(message))
            }
            guard let section = section(at: indexPath) else {
                return .setPhase(.error("Invalid section"))
            }
            switch section {
            case .folder(let folder):
                _ = try await deleteFolderUseCase.execute(folder).get()
            case .clip(let clip):
                _ = try await deleteClipUseCase.execute(clip).get()
            }
            return .setPhase(.success)
        }
        .catch { error in
            .just(.setPhase(.error(error.localizedDescription)))
        }
    }

    func section(at indexPath: IndexPath) -> SectionType? {
        switch indexPath.section {
        case 0:
            guard folder.folders.indices.contains(indexPath.item) else {
                return nil
            }
            return .folder(folder.folders[indexPath.item])
        case 1:
            guard folder.clips.indices.contains(indexPath.item) else {
                return nil
            }
            return .clip(folder.clips[indexPath.item])
        default:
            return nil
        }
    }
}
