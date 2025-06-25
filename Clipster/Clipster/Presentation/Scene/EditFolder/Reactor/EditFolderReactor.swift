import Foundation
import ReactorKit

final class EditFolderReactor: Reactor {
    enum Action {
        case viewDidAppear
        case folderTitleChanged(String)
        case saveButtonTapped
        case clearButtonTapped
        case folderViewTapped
        case selectFolder(selected: Folder?)
        case folderSelectorDismissed
    }

    enum Mutation {
        case updateTitleAndSavability(title: String, isSavable: Bool)
        case setParentFolder(Folder?)
        case setPhase(State.Phase)
        case setRoute(State.Route?)
        case updateIsShowKeyboard(Bool)
    }

    struct State {
        var folderTitle: String = ""
        let folder: Folder?
        let initialParentFolder: Folder?
        var parentFolder: Folder?
        var parentFolderDisplay: FolderDisplay?
        var isSavable = false
        var isShowKeyboard: Bool = false

        @Pulse var phase: Phase = .idle
        @Pulse var route: Route?

        enum Phase {
            case idle
            case loading
            case success(folder: Folder)
            case error(String)
        }

        enum Route {
            case showFolderSelector
        }

        var navigationTitle: String {
            folder == nil ? "폴더 추가" : "폴더 편집"
        }
    }

    let initialState: State
    private let canSaveFolderUseCase: CanSaveFolderUseCase
    private let sanitizeFolderTitleUseCase: SanitizeFolderTitleUseCase
    private let createFolderUseCase: CreateFolderUseCase
    private let updateFolderUseCase: UpdateFolderUseCase

    init(
        canSaveFolderUseCase: CanSaveFolderUseCase,
        sanitizeFolderTitleUseCase: SanitizeFolderTitleUseCase,
        createFolderUseCase: CreateFolderUseCase,
        updateFolderUseCase: UpdateFolderUseCase,
        parentFolder: Folder?,
        folder: Folder?
    ) {
        self.canSaveFolderUseCase = canSaveFolderUseCase
        self.sanitizeFolderTitleUseCase = sanitizeFolderTitleUseCase
        self.createFolderUseCase = createFolderUseCase
        self.updateFolderUseCase = updateFolderUseCase
        var initialState = State(folder: folder, initialParentFolder: parentFolder)
        let initialTitle = folder?.title ?? ""
        initialState.folderTitle = initialTitle
        initialState.parentFolder = parentFolder
        initialState.parentFolderDisplay = parentFolder.map { FolderDisplayMapper.map($0) }
        initialState.isSavable = canSaveFolderUseCase.execute(title: initialTitle)
        self.initialState = initialState
    }

    func mutate(action: Action) -> Observable<Mutation> {
        print("\(Self.self): Received action: \(action)")
        switch action {
        case .folderTitleChanged(let title):
            print("\(Self.self): Title changed to: \(title)")
            let sanitizedTitle = sanitizeFolderTitleUseCase.execute(title: title)
            let isSavable = canSaveFolderUseCase.execute(title: sanitizedTitle)
            return .just(.updateTitleAndSavability(title: sanitizedTitle, isSavable: isSavable))
        case .clearButtonTapped:
            print("\(Self.self): Clear button Tapped")
            let isSavable = canSaveFolderUseCase.execute(title: "")
            return .just(.updateTitleAndSavability(title: "", isSavable: isSavable))
        case .selectFolder(let folder):
            print("\(Self.self): Folder selected: \(folder?.title ?? "Home")")
            return .just(.setParentFolder(folder))
        case .saveButtonTapped:
            print("\(Self.self): Save button Tapped")
            guard currentState.isSavable else { return .empty() }
            return .concat(
                .just(.setPhase(.loading)),

                .fromAsync { [weak self] in
                    guard let self = self else { throw DomainError.unknownError }

                    let title = currentState.folderTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                    let date = Date()

                    if let folder = currentState.folder {
                        let updatedFolder = Folder(
                            id: folder.id,
                            parentFolderID: currentState.parentFolder?.id,
                            title: title,
                            depth: (currentState.parentFolder?.depth ?? -1) + 1,
                            folders: folder.folders,
                            clips: folder.clips,
                            createdAt: folder.createdAt,
                            updatedAt: date,
                            deletedAt: folder.deletedAt
                        )
                        _ = try await updateFolderUseCase.execute(updatedFolder).get()

                        return .setPhase(.success(folder: updatedFolder))
                    } else {
                        let newFolder = Folder(
                            id: UUID(),
                            parentFolderID: currentState.parentFolder?.id,
                            title: title,
                            depth: (currentState.parentFolder?.depth ?? -1) + 1,
                            folders: [],
                            clips: [],
                            createdAt: date,
                            updatedAt: date,
                            deletedAt: nil
                        )
                        _ = try await createFolderUseCase.execute(newFolder).get()

                        return .setPhase(.success(folder: newFolder))
                    }
                }
                .catch { error in
                    .just(.setPhase(.error(error.localizedDescription)))
                }
            )
        case .folderViewTapped:
            return .just(.setRoute(.showFolderSelector))
        case .folderSelectorDismissed:
            return .just(.setRoute(nil))
        case .viewDidAppear:
            return .just(.updateIsShowKeyboard(true))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        print("\(Self.self): Applying mutation: \(mutation)")
        var newState = state
        newState.route = nil

        switch mutation {
        case .updateTitleAndSavability(let title, let isSavable):
            print("\(Self.self): Title updated to: \(title), isSavable: \(isSavable)")
            newState.folderTitle = title
            newState.isSavable = isSavable
        case .setParentFolder(let folder):
            print("\(Self.self): Parent folder set")
            newState.parentFolder = folder
            newState.parentFolderDisplay = folder.map { FolderDisplayMapper.map($0) }
        case .setPhase(let phase):
            print("\(Self.self): Phase changed to: \(phase)")
            newState.phase = phase
        case .setRoute(let route):
            print("\(Self.self): Navigate to: \(route.debugDescription)")
            newState.route = route
        case .updateIsShowKeyboard(let value):
            print("\(Self.self): Show keyboard updated to: \(value)")
            newState.isShowKeyboard = value
        }

        return newState
    }
}
