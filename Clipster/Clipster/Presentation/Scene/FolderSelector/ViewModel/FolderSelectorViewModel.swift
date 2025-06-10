import RxRelay
import RxSwift

enum FolderSelectorMode {
    case clip(parentFolder: Folder?)
    case folder(parentFolder: Folder?)
}

enum FolderSelectorAction {
    case viewDidLoad
    case viewWillDisappear
    case dataLoadedSucceeded(folders: [Folder])
    case dataLoadFailed(Error)
    case openSubfolder(folder: Folder)
    case navigateUp
    case selectButtonTapped
    case addButtonTapped
    case folderAdded(folder: Folder)
}

struct FolderSelectorState {
    let mode: FolderSelectorMode
    var folders: [Folder] = []
    var currentPath: [Folder] = []
    var isLoading = true
    var errorMessage: String?
    var didFinishSelection: Folder?
    var shouldDismiss = false

    var subfolders: [Folder] {
        currentPath.last?.folders ?? folders
    }

    var selectedFolder: Folder? {
        currentPath.last
    }

    var title: String {
        selectedFolder?.title ?? ""
    }

    var canNavigateUp: Bool {
        !currentPath.isEmpty
    }

    var isAddButtonHidden: Bool {
        switch mode {
        case .clip:
            return false
        case .folder:
            return true
        }
    }
}

final class FolderSelectorViewModel {
    private let fetchTopLevelFoldersUseCase: FetchTopLevelFoldersUseCase
    private let disposeBag = DisposeBag()

    private let stateRelay: BehaviorRelay<FolderSelectorState>

    let action = PublishRelay<FolderSelectorAction>()
    let state: Observable<FolderSelectorState>

    init(
        fetchTopLevelFoldersUseCase: FetchTopLevelFoldersUseCase,
        mode: FolderSelectorMode
    ) {
        self.fetchTopLevelFoldersUseCase = fetchTopLevelFoldersUseCase

        let initialState = FolderSelectorState(mode: mode)
        self.stateRelay = BehaviorRelay(value: initialState)
        self.state = stateRelay.asObservable()

        action
            .filter { if case .viewDidLoad = $0 { return true } else { return false } }
            .flatMapLatest { [weak self] _ -> Observable<FolderSelectorAction> in
                guard let self else { return .empty() }

                print("\(Self.self): fetching top-level folders")

                return Single<[Folder]>.create { single in
                    Task {
                        let result = await self.fetchTopLevelFoldersUseCase.execute()

                        switch result {
                        case .success(let folders):
                            single(.success(folders))
                        case .failure(let error):
                            single(.failure(error))
                        }
                    }
                    return Disposables.create()
                }
                .map { .dataLoadedSucceeded(folders: $0) }
                .catch { .just(.dataLoadFailed($0)) }
                .asObservable()
            }
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: action)
            .disposed(by: disposeBag)

        action
            .do { action in
                print("\(Self.self): received action → \(action)")
            }
            .scan(into: initialState) { state, action in
                state.errorMessage = nil
                state.didFinishSelection = nil

                switch action {
                case .viewDidLoad:
                    print("\(Self.self): viewDidLoad")
                    state.isLoading = true
                case .viewWillDisappear:
                    print("\(Self.self): viewWillDisappear")
                    state.shouldDismiss = true
                case .dataLoadedSucceeded(let folders):
                    print("\(Self.self): data load succeeded with \(folders.count) folders")
                    state.isLoading = false
                    state.folders = folders

                    if let parentFolder = {
                        switch state.mode {
                        case .clip(let folder), .folder(let folder):
                            return folder
                        }
                    }(), let path = self.path(to: parentFolder, in: folders) {
                        state.currentPath = path
                        print("\(Self.self): initial path set to → \(path.map { $0.title })")
                    } else {
                        print("\(Self.self): no initial folder or failed to find path")
                    }
                case .dataLoadFailed(let error):
                    print("\(Self.self): data load failed with error: \(error.localizedDescription)")
                    state.isLoading = false
                    state.errorMessage = "폴더 목록을 불러오는데 실패했습니다: \(error.localizedDescription)"
                case .openSubfolder(let folder):
                    print("\(Self.self): open folder \(folder.title)")
                    state.currentPath.append(folder)
                case .navigateUp:
                    if !state.currentPath.isEmpty {
                        let removed = state.currentPath.removeLast()
                        print("\(Self.self): moved up from folder \(removed.title)")
                    }
                case .selectButtonTapped:
                    if let selected = state.selectedFolder {
                        print("\(Self.self): selected folder \(selected.title)")
                        state.didFinishSelection = selected
                        state.shouldDismiss = true
                    } else {
                        print("\(Self.self): no folder selected")
                    }
                case .addButtonTapped:
                    print("\(Self.self): add button tapped")
                case .folderAdded(let folder):
                    print("\(Self.self): added folder \(folder.title)")
                    state.didFinishSelection = folder
                }
            }
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
    }

    private func path(to target: Folder, in folders: [Folder]) -> [Folder]? {
        for folder in folders {
            if folder.id == target.id {
                return [folder]
            } else if let subpath = path(to: target, in: folder.folders) {
                return [folder] + subpath
            }
        }
        return nil
    }
}
