import Foundation
import ReactorKit
import RxSwift

final class FolderSelectorReactor: Reactor {
    enum Action {
        case viewDidLoad
        case selectedFolder(id: UUID)
        case toggleExpansion(id: UUID)
        case backButtonTapped
        case selectButtonTapped
    }

    enum Mutation {
        case setInitialData(isAccordion: Bool, topLevelFolders: [Folder], path: [Folder], expandedFolderIDs: Set<UUID>, highlightedFolderID: UUID)
        case updateNavigation(path: [Folder])
        case setToggleExpansion(id: UUID)
        case setHighlightedFolder(id: UUID?)
        case setPhase(State.Phase)
    }

    struct State {
        var isAccordion = true
        static let homeFolderID = UUID()
        var topLevelFolders: [Folder] = []
        var currentPath: [Folder] = []
        var expandedFolderIDs: Set<UUID> = []
        var highlightedFolderID: UUID?
        var displayableFolders: [FolderDisplay] = []

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
            if isAccordion {
                if let folderID = highlightedFolderID,
                   let highlightedFolder = displayableFolders.first(where: { $0.id == folderID }) {
                    return highlightedFolder.title
                }
                return "홈"
            } else {
                return selectedFolder?.title ?? "홈"
            }
        }
    }

    let initialState: State
    private let fetchTopLevelFoldersUseCase: FetchTopLevelFoldersUseCase
    private let findFolderPathUseCase: FindFolderPathUseCase
    private let filterSubfoldersUseCase: FilterSubfoldersUseCase
    private let fetchSavePathLayoutOptionUseCase: FetchSavePathLayoutOptionUseCase

    private let parentFolder: Folder?
    private let folder: Folder?

    init(
        fetchTopLevelFoldersUseCase: FetchTopLevelFoldersUseCase,
        findFolderPathUseCase: FindFolderPathUseCase,
        filterSubfoldersUseCase: FilterSubfoldersUseCase,
        fetchSavePathLayoutOptionUseCase: FetchSavePathLayoutOptionUseCase,
        parentFolder: Folder?,
        folder: Folder?
    ) {
        self.initialState = State()
        self.fetchTopLevelFoldersUseCase = fetchTopLevelFoldersUseCase
        self.findFolderPathUseCase = findFolderPathUseCase
        self.filterSubfoldersUseCase = filterSubfoldersUseCase
        self.fetchSavePathLayoutOptionUseCase = fetchSavePathLayoutOptionUseCase
        self.parentFolder = parentFolder
        self.folder = folder
    }

    convenience init(
        fetchTopLevelFoldersUseCase: FetchTopLevelFoldersUseCase,
        findFolderPathUseCase: FindFolderPathUseCase,
        filterSubfoldersUseCase: FilterSubfoldersUseCase,
        fetchSavePathLayoutOptionUseCase: FetchSavePathLayoutOptionUseCase,
        parentFolder: Folder?
    ) {
        self.init(
            fetchTopLevelFoldersUseCase: fetchTopLevelFoldersUseCase,
            findFolderPathUseCase: findFolderPathUseCase,
            filterSubfoldersUseCase: filterSubfoldersUseCase,
            fetchSavePathLayoutOptionUseCase: fetchSavePathLayoutOptionUseCase,
            parentFolder: parentFolder,
            folder: nil
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
                    let isAccordionResult = try await fetchSavePathLayoutOptionUseCase.execute().get()
                    let folders = try await fetchTopLevelFoldersUseCase.execute().get()

                    let filteredFolders = folder.flatMap {
                        self.filterSubfoldersUseCase.execute($0, from: folders)
                    } ?? folders

                    let path: [Folder]
                    var expandedFolderIDs: Set<UUID>

                    if let parentFolder = parentFolder {
                        path = findFolderPathUseCase.execute(to: parentFolder, in: folders) ?? []
                        expandedFolderIDs = Set(path.map { $0.id })
                        expandedFolderIDs.insert(State.homeFolderID)
                    } else {
                        path = []
                        expandedFolderIDs = []
                    }

                    let highlightedFolderID = parentFolder?.id ?? State.homeFolderID

                    return .setInitialData(
                        isAccordion: isAccordionResult == .expand,
                        topLevelFolders: filteredFolders,
                        path: path,
                        expandedFolderIDs: expandedFolderIDs,
                        highlightedFolderID: highlightedFolderID
                    )
                },

                .just(.setPhase(.idle))
            )
        case .selectedFolder(let id):
            print("\(Self.self): Navigate to: \(id)")
            if currentState.isAccordion {
                return .just(.setHighlightedFolder(id: id))
            } else {
                guard let folder = findFolder(withId: id, in: currentState.topLevelFolders) else { return .empty() }
                let newPath = currentState.currentPath + [folder]
                return .just(.updateNavigation(path: newPath))
            }
        case .toggleExpansion(let id):
            return .just(.setToggleExpansion(id: id))
        case .backButtonTapped:
            print("\(Self.self): Navigate up")
            guard !currentState.isAccordion, !currentState.currentPath.isEmpty else { return .empty() }
            var path = currentState.currentPath
            path.removeLast()
            return .just(.updateNavigation(path: path))
        case .selectButtonTapped:
            print("\(Self.self): Folder selected: \(currentState.selectedFolder?.title ?? "Home")")
            if currentState.isAccordion {
                if let highlightedID = currentState.highlightedFolderID {
                    if highlightedID == State.homeFolderID {
                        return .just(.setPhase(.success(selected: nil)))
                    } else {
                        let folder = findFolder(withId: highlightedID, in: currentState.topLevelFolders)
                        return .just(.setPhase(.success(selected: folder)))
                    }
                }
                return .just(.setPhase(.success(selected: nil)))
            } else {
                return .just(.setPhase(.success(selected: currentState.selectedFolder)))
            }
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        print("\(Self.self): Applying mutation: \(mutation)")
        var newState = state
        var needsDisplayUpdate = false
        switch mutation {
        case .setInitialData(let isAccordion, let topLevelFolders, let path, let expandedFolderIDs, let highlightedFolderID):
            print("\(Self.self): Initial Data set")
            newState.isAccordion = isAccordion
            newState.topLevelFolders = topLevelFolders
            newState.currentPath = path
            newState.expandedFolderIDs = expandedFolderIDs
            newState.highlightedFolderID = highlightedFolderID
            needsDisplayUpdate = true
        case .updateNavigation(let path):
            print("\(Self.self): Navigation update")
            newState.currentPath = path
            needsDisplayUpdate = true
        case .setToggleExpansion(let id):
            if newState.expandedFolderIDs.contains(id) {
                newState.expandedFolderIDs.remove(id)
            } else {
                newState.expandedFolderIDs.insert(id)
            }
            needsDisplayUpdate = true
        case .setHighlightedFolder(let id):
            newState.highlightedFolderID = id
            needsDisplayUpdate = true
        case .setPhase(let phase):
            print("\(Self.self): Phase changed to: \(phase)")
            newState.phase = phase
        }

        if needsDisplayUpdate {
            let folders = calculateFoldersToDisplay(from: newState)

            newState.displayableFolders = folders.map { folder in
                let isExpanded = newState.expandedFolderIDs.contains(folder.id)
                let isHighlighted = (folder.id == newState.highlightedFolderID)
                return FolderDisplayMapper.map(folder, isExpanded: isExpanded, isHighlighted: isHighlighted)
            }

            if newState.isAccordion {
                let count = newState.topLevelFolders.count
                let isExpanded = newState.expandedFolderIDs.contains(State.homeFolderID)
                let isHighlighted = (State.homeFolderID == newState.highlightedFolderID)
                let homeFolder = FolderDisplay(
                    id: State.homeFolderID,
                    title: "홈",
                    depth: -1,
                    itemCount: "",
                    folderCount: "\(count)",
                    isExpanded: isExpanded,
                    isHighlighted: isHighlighted,
                    hasSubfolders: ![0].contains(count)
                )

                newState.displayableFolders = isExpanded ? [homeFolder] + newState.displayableFolders : [homeFolder]
            }
        }

        return newState
    }
}

private extension FolderSelectorReactor {
    func calculateFoldersToDisplay(from state: State) -> [Folder] {
        if state.isAccordion {
            guard state.expandedFolderIDs.contains(State.homeFolderID) else { return [] }
            return flattenFolders(folders: state.topLevelFolders, expandedIDs: state.expandedFolderIDs)
        } else {
            var currentFolders = state.topLevelFolders
            for folderInPath in state.currentPath {
                if let nextLevel = currentFolders.first(where: { $0.id == folderInPath.id })?.folders {
                    currentFolders = nextLevel
                } else { return [] }
            }
            return currentFolders
        }
    }

    func mapFoldersToDisplay(folders: [Folder], expandedIDs: Set<UUID>, highlightedID: UUID?) -> [FolderDisplay] {
        folders.map { folder in
            let isExpanded = expandedIDs.contains(folder.id)
            let isHighlighted = (folder.id == highlightedID)
            return FolderDisplayMapper.map(folder, isExpanded: isExpanded, isHighlighted: isHighlighted)
        }
    }

    func flattenFolders(folders: [Folder], expandedIDs: Set<UUID>) -> [Folder] {
        var flattenedList: [Folder] = []
        for folder in folders {
            flattenedList.append(folder)
            if expandedIDs.contains(folder.id), !folder.folders.isEmpty {
                flattenedList.append(contentsOf: flattenFolders(folders: folder.folders, expandedIDs: expandedIDs))
            }
        }
        return flattenedList
    }

    func findFolder(withId folderId: UUID, in folders: [Folder]) -> Folder? {
        for folder in folders {
            if folder.id == folderId { return folder }
            if let found = findFolder(withId: folderId, in: folder.folders) {
                return found
            }
        }
        return nil
    }
}
