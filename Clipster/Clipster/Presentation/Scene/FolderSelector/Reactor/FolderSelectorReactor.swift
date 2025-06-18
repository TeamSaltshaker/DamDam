import ReactorKit
import RxSwift

final class FolderSelectorReactor: Reactor {
    enum Action {
        case viewDidLoad
        case navigateTo(Folder)
        case navigateUp
        case selectButtonTapped
    }

    enum Mutation {
        case setInitialData(topLevelFolders: [Folder], path: [Folder], filteredSubfolders: [Folder], isSelectable: Bool)
        case updateNavigation(path: [Folder], filteredSubfolders: [Folder], isSelectable: Bool)
        case setPhase(State.Phase)
    }

    struct State {
        let isClip: Bool
        var parentFolder: Folder?
        var folder: Folder?
        var topLevelFolders: [Folder] = []
        var currentPath: [Folder] = []
        var filteredSubfolders: [Folder] = []
        var isSelectable = false

        @Pulse var phase: Phase = .idle

        enum Phase {
            case idle
            case loading
            case success(selected: Folder?)
            case error(String)
        }

        var selectedFolder: Folder? {
            currentPath.last
        }

        var title: String {
            selectedFolder?.title ?? "홈"
        }

        var canNavigateUp: Bool {
            !currentPath.isEmpty
        }
    }

    let initialState: State
    private let fetchTopLevelFoldersUseCase: FetchTopLevelFoldersUseCase
    private let canSelectFolderUseCase: CanSelectFolderUseCase
    private let findFolderPathUseCase: FindFolderPathUseCase
    private let filterSubfoldersUseCase: FilterSubfoldersUseCase

    private init(
        fetchTopLevelFoldersUseCase: FetchTopLevelFoldersUseCase,
        canSelectFolderUseCase: CanSelectFolderUseCase,
        findFolderPathUseCase: FindFolderPathUseCase,
        filterSubfoldersUseCase: FilterSubfoldersUseCase,
        isClip: Bool,
        parentFolder: Folder?,
        folder: Folder?
    ) {
        self.fetchTopLevelFoldersUseCase = fetchTopLevelFoldersUseCase
        self.canSelectFolderUseCase = canSelectFolderUseCase
        self.findFolderPathUseCase = findFolderPathUseCase
        self.filterSubfoldersUseCase = filterSubfoldersUseCase
        self.initialState = State(isClip: isClip, parentFolder: parentFolder, folder: folder)
    }

    convenience init(
        fetchTopLevelFoldersUseCase: FetchTopLevelFoldersUseCase,
        canSelectFolderUseCase: CanSelectFolderUseCase,
        findFolderPathUseCase: FindFolderPathUseCase,
        filterSubfoldersUseCase: FilterSubfoldersUseCase,
        parentFolder: Folder?
    ) {
        self.init(
            fetchTopLevelFoldersUseCase: fetchTopLevelFoldersUseCase,
            canSelectFolderUseCase: canSelectFolderUseCase,
            findFolderPathUseCase: findFolderPathUseCase,
            filterSubfoldersUseCase: filterSubfoldersUseCase,
            isClip: true,
            parentFolder: parentFolder,
            folder: nil
        )
    }

    convenience init(
        fetchTopLevelFoldersUseCase: FetchTopLevelFoldersUseCase,
        canSelectFolderUseCase: CanSelectFolderUseCase,
        findFolderPathUseCase: FindFolderPathUseCase,
        filterSubfoldersUseCase: FilterSubfoldersUseCase,
        parentFolder: Folder?,
        folder: Folder?
    ) {
        self.init(
            fetchTopLevelFoldersUseCase: fetchTopLevelFoldersUseCase,
            canSelectFolderUseCase: canSelectFolderUseCase,
            findFolderPathUseCase: findFolderPathUseCase,
            filterSubfoldersUseCase: filterSubfoldersUseCase,
            isClip: false,
            parentFolder: parentFolder,
            folder: folder
        )
    }

    func mutate(action: Action) -> Observable<Mutation> {
        print("\(Self.self): Received action: \(action)")

        switch action {
        case .viewDidLoad:
            print("\(Self.self): viewDidLoad")
            return .concat(
                .just(.setPhase(.loading)),

                .fromAsync { [weak self] in
                    guard let self else { throw DomainError.unknownError }

                    let folders = try await fetchTopLevelFoldersUseCase.execute().get()
                    let path = currentState.parentFolder.flatMap {
                        self.findFolderPathUseCase.execute(to: $0, in: folders)
                    } ?? []
                    let navigationData = calculateNavigationState(for: path, from: folders)

                    return .setInitialData(
                        topLevelFolders: folders,
                        path: path,
                        filteredSubfolders: navigationData.filteredSubfolders,
                        isSelectable: navigationData.isSelectable
                    )
                }
                .catch { error in
                    .just(.setPhase(.error(error.localizedDescription)))
                },

                .just(.setPhase(.idle))
            )
        case .navigateTo(let folder):
            print("\(Self.self): Navigate to: \(folder.title)")
            let path = currentState.currentPath + [folder]
            return .just(makeNavigationMutation(for: path, from: currentState.topLevelFolders))
        case .navigateUp:
            print("\(Self.self): Navigate up")
            var path = currentState.currentPath
            _ = path.popLast()
            return .just(makeNavigationMutation(for: path, from: currentState.topLevelFolders))
        case .selectButtonTapped:
            print("\(Self.self): Folder selected: \(currentState.selectedFolder?.title ?? "Home")")
            guard currentState.isSelectable else { return .empty() }
            return .just(.setPhase(.success(selected: currentState.selectedFolder)))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        print("\(Self.self): Applying mutation: \(mutation)")
        var newState = state
        switch mutation {
        case .setInitialData(let topLevelFolders, let path, let filteredSubfolders, let isSelectable):
            print("\(Self.self): Initial Data set")
            newState.topLevelFolders = topLevelFolders
            newState.currentPath = path
            newState.filteredSubfolders = filteredSubfolders
            newState.isSelectable = isSelectable
        case .updateNavigation(let path, let filteredSubfolders, let isSelectable):
            print("\(Self.self): Navigation update")
            newState.currentPath = path
            newState.filteredSubfolders = filteredSubfolders
            newState.isSelectable = isSelectable
        case .setPhase(let phase):
            print("\(Self.self): Phase changed to: \(phase)")
            newState.phase = phase
        }
        return newState
    }
}

private extension FolderSelectorReactor {
    private func calculateNavigationState(for path: [Folder], from topLevelFolders: [Folder]) -> (filteredSubfolders: [Folder], isSelectable: Bool) {
        let filteredSubfolders = filterSubfoldersUseCase.execute(
            topLevelFolders: topLevelFolders,
            currentPath: path,
            folder: initialState.folder
        )
        let isSelectable = canSelectFolderUseCase.execute(
            selectedFolder: path.last,
            isClip: initialState.isClip
        )
        return (filteredSubfolders, isSelectable)
    }

    private func makeNavigationMutation(for path: [Folder], from topLevelFolders: [Folder]) -> Mutation {
        let (filteredSubfolders, isSelectable) = calculateNavigationState(for: path, from: topLevelFolders)
        return .updateNavigation(path: path, filteredSubfolders: filteredSubfolders, isSelectable: isSelectable)
    }
}
