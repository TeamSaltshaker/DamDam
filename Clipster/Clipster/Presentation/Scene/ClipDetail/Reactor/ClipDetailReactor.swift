import ReactorKit
import RxSwift

final class ClipDetailReactor: Reactor {
    enum Action {
        case viewWillAppear
        case editButtonTapped
        case deleteButtonTapped
        case deleteConfirmed
    }

    enum Mutation {
        case setInitialData(clip: Clip, folder: Folder?)
        case setPhase(State.Phase)
        case setRoute(State.Route?)
    }

    struct State {
        var clip: Clip
        var clipDisplay: ClipDisplay
        var folder: Folder?
        var folderDisplay: FolderDisplay?

        @Pulse var phase: Phase = .idle
        @Pulse var route: Route?

        enum Phase {
            case idle
            case loading
            case success
            case error(String)
        }

        enum Route {
            case showEditClip(Clip)
            case showDeleteConfirmation(title: String)
        }

        init(clip: Clip) {
            self.clip = clip
            self.clipDisplay = ClipDisplayMapper.map(clip)
        }
    }

    let initialState: State
    private let fetchFolderUseCase: FetchFolderUseCase
    private let deleteClipUseCase: DeleteClipUseCase
    private let fetchClipUseCase: FetchClipUseCase

    private var isFirstAppear = true

    init(
        fetchFolderUseCase: FetchFolderUseCase,
        deleteClipUseCase: DeleteClipUseCase,
        fetchClipUseCase: FetchClipUseCase,
        clip: Clip
    ) {
        self.fetchFolderUseCase = fetchFolderUseCase
        self.deleteClipUseCase = deleteClipUseCase
        self.fetchClipUseCase = fetchClipUseCase
        self.initialState = State(clip: clip)
    }

    func mutate(action: Action) -> Observable<Mutation> {
        print("\(Self.self): Received action: \(action)")

        switch action {
        case .viewWillAppear:
            print("\(Self.self): viewWillAppear")
            if isFirstAppear {
                isFirstAppear = false
                return .concat(
                    .just(.setPhase(.loading)),

                    .fromAsync { [weak self] in
                        guard let self = self else { throw DomainError.unknownError }

                        if let folderID = currentState.clip.folderID {
                            let folder = try await fetchFolderUseCase.execute(id: folderID).get()
                            return .setInitialData(clip: currentState.clip, folder: folder)
                        } else {
                            return .setInitialData(clip: currentState.clip, folder: nil)
                        }
                    }
                    .catch { error in
                        .just(.setPhase(.error(error.localizedDescription)))
                    },

                    .just(.setPhase(.idle))
                )
            } else {
                return .concat(
                    .just(.setPhase(.loading)),

                    .fromAsync { [weak self] in
                        guard let self = self else { throw DomainError.unknownError }

                        let clip = try await fetchClipUseCase.execute(id: currentState.clip.id).get()
                        if let folderID = clip.folderID {
                            let folder = try await fetchFolderUseCase.execute(id: folderID).get()
                            return .setInitialData(clip: currentState.clip, folder: folder)
                        } else {
                            return .setInitialData(clip: currentState.clip, folder: nil)
                        }
                    }
                    .catch { error in
                        .just(.setPhase(.error(error.localizedDescription)))
                    },

                    .just(.setPhase(.idle))
                )
            }
        case .editButtonTapped:
            print("\(Self.self): Edit button tapped")
            return .just(.setRoute(.showEditClip(currentState.clip)))
        case .deleteButtonTapped:
            print("\(Self.self): Delete button tapped")
            let title = currentState.clipDisplay.urlMetadata.title
            return .just(.setRoute(.showDeleteConfirmation(title: title)))
        case .deleteConfirmed:
            print("\(Self.self): Delete confirmed")
            return .concat(
                .just(.setPhase(.loading)),

                .fromAsync { [weak self] in
                    guard let self = self else { throw DomainError.unknownError }
                    _ = try await deleteClipUseCase.execute(currentState.clip).get()
                    return .setPhase(.success)
                }
                .catch { .just(.setPhase(.error($0.localizedDescription))) }
            )
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        print("\(Self.self): Applying mutation: \(mutation)")

        var newState = state
        newState.route = nil

        switch mutation {
        case .setInitialData(let clip, let folder):
            print("\(Self.self): Initial Data set")
            newState.clip = clip
            newState.folder = folder
            newState.clipDisplay = ClipDisplayMapper.map(clip)
            newState.folderDisplay = folder.map { FolderDisplayMapper.map($0) }
        case .setPhase(let phase):
            print("\(Self.self): Phase changed to: \(phase)")
            newState.phase = phase
        case .setRoute(let route):
            print("\(Self.self): Navigate to: \(route.debugDescription)")
            newState.route = route
        }
        return newState
    }
}
