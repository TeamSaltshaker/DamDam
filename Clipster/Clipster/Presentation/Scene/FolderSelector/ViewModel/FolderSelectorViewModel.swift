import RxRelay
import RxSwift

enum FolderSelectorMode {
    case clip
    case folder
}

enum FolderSelectorAction {
    case viewDidLoad
    case dataLoaded(folders: [Folder])
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
        mode == .folder
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
                .map { .dataLoaded(folders: $0) }
                .catch { .just(.dataLoadFailed($0)) }
                .asObservable()
            }
            .bind(to: action)
            .disposed(by: disposeBag)

        action
            .do(onNext: { action in
                print("\(Self.self): received action → \(action)")
            })
            .scan(into: initialState) { state, action in
                state.errorMessage = nil
                state.didFinishSelection = nil

                switch action {
                case .viewDidLoad:
                    print("\(Self.self): viewDidLoad")
                    state.isLoading = true
                case .dataLoaded(let folders):
                    print("\(Self.self): data load succeeded with \(folders.count) folders")
                    state.isLoading = false
                    state.folders = folders
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
}
