import RxRelay
import RxSwift

enum EditFolderMode {
    case add(parentFolder: Folder?)
    case edit(parentFolder: Folder?, folder: Folder)
}

enum EditFolderAction {
    case folderTitleChanged(String)
    case saveButtonTapped
    case saveSucceeded
    case saveFailed(Error)
}

struct EditFolderState {
    let mode: EditFolderMode
    var folderTitle: String
    let initialFolderTitle: String

    var isSavable: Bool {
        let trimmed = folderTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return false
        }

        switch mode {
        case .add:
            return true
        case .edit:
            return trimmed != initialFolderTitle
        }
    }

    var isProcessing: Bool = false
    var shouldDismiss: Bool = false
    var alertMessage: String?

    init(mode: EditFolderMode) {
        self.mode = mode
        switch mode {
        case .add:
            self.folderTitle = ""
            self.initialFolderTitle = ""
        case .edit(_, let folder):
            self.folderTitle = folder.title
            self.initialFolderTitle = folder.title
        }
    }
}

final class EditFolderViewModel {
    private let disposeBag = DisposeBag()

    private let stateRelay: BehaviorRelay<EditFolderState>

    let action = PublishRelay<EditFolderAction>()
    let state: Observable<EditFolderState>

    init(mode: EditFolderMode) {
        let initialState = EditFolderState(mode: mode)
        self.stateRelay = BehaviorRelay(value: initialState)
        self.state = self.stateRelay.asObservable()

        action
            .do { action in
                print("\(Self.self): received action → \(action)")
            }
            .scan(initialState) { state, action in
                var newState = state
                newState.alertMessage = nil

                switch action {
                case .folderTitleChanged(let title):
                    print("\(Self.self): folder title changed to '\(title)'")
                    newState.folderTitle = title
                case .saveButtonTapped:
                    if newState.isSavable {
                        print("\(Self.self): save button tapped")
                        newState.isProcessing = true
                    }
                case .saveSucceeded:
                    print("\(Self.self): save succeeded")
                    newState.isProcessing = false
                    newState.shouldDismiss = true
                case .saveFailed(let error):
                    print("\(Self.self): save failed with error: \(error.localizedDescription)")
                    newState.isProcessing = false
                    newState.alertMessage = error.localizedDescription
                }

                return newState
            }
            .bind(to: stateRelay)
            .disposed(by: disposeBag)

        action
            .filter { if case .saveButtonTapped = $0 { return true } else { return false } }
            .withLatestFrom(stateRelay)
            .filter { $0.isSavable }
            .flatMapLatest { currentState in
                let title = currentState.folderTitle.trimmingCharacters(in: .whitespacesAndNewlines)

                switch currentState.mode {
                case .add(let parentFolder):
                    print("\(Self.self): attempting to add folder '\(title)' to parent '\(parentFolder?.title ?? "root")'")
                    return Observable<EditFolderAction>.just(.saveSucceeded)
                case .edit(let parentFolder, let folder):
                    print("\(Self.self): attempting to edit folder \(folder.id) set title to '\(title)', parent to '\(parentFolder?.title ?? "root")'")
                    return Observable<EditFolderAction>.just(.saveSucceeded)
                }
            }
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: action)
            .disposed(by: disposeBag)
    }
}
