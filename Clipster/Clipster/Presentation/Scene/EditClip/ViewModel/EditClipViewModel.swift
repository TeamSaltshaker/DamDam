import Foundation
import RxRelay
import RxSwift

final class EditClipViewModel: ViewModel {
    enum EditClipType {
        case edit
        case create
        case shareExtension
    }

    enum Action {
        case editURLInputTextField(String)
        case editMomo(String)
        case folderViewTapped
        case editFolder(Folder?)
    }

    enum Mutation {
        case updateURLInputText(String)
        case updateMemo(String)
        case updateValidURL(Bool)
        case updateURLMetadata(URLMetadataDisplay?)
        case updateFolderViewTapped(Bool)
        case updateCurrentFolder(Folder?)
    }

    struct State {
        var type: EditClipType
        var urlInputText: String
        var isHiddenURLMetadataStackView = true
        var isHiddenURLValidationStackView = true
        var memoText: String = ""
        var memoLimit: String = "0/100"
        var isURLValid = false
        var urlValidationImageName: String = ""
        var urlValidationLabelText: String = ""
        var urlMetadata: URLMetadataDisplay?
        var isFolderViewTapped: Bool = false
        var clip: Clip?
        var currentFolder: Folder?
    }

    var state: BehaviorRelay<State>
    var action = PublishRelay<Action>()
    var disposeBag = DisposeBag()

    private let checkURLValidityUseCase: CheckURLValidityUseCase
    private let parseURLMetadataUseCase: ParseURLMetadataUseCase
    private let fetchFolderUseCase: FetchFolderUseCase
    private let createClipUseCase: CreateClipUseCase
    private let updateClipUseCase: UpdateClipUseCase

    init(
        urlText: String = "",
        currentFolder: Folder? = nil,
        checkURLValidityUseCase: CheckURLValidityUseCase,
        parseURLMetadataUseCase: ParseURLMetadataUseCase,
        fetchFolderUseCase: FetchFolderUseCase,
        createClipUseCase: CreateClipUseCase,
        updateClipUseCase: UpdateClipUseCase
    ) {
        state = BehaviorRelay(value: State(
            type: urlText.isEmpty ? .create : .shareExtension,
            urlInputText: urlText,
            currentFolder: currentFolder
        ))
        self.checkURLValidityUseCase = checkURLValidityUseCase
        self.parseURLMetadataUseCase = parseURLMetadataUseCase
        self.fetchFolderUseCase = fetchFolderUseCase
        self.createClipUseCase = createClipUseCase
        self.updateClipUseCase = updateClipUseCase
        bind()
    }

    init(
        clip: Clip,
        checkURLValidityUseCase: CheckURLValidityUseCase,
        parseURLMetadataUseCase: ParseURLMetadataUseCase,
        fetchFolderUseCase: FetchFolderUseCase,
        createClipUseCase: CreateClipUseCase,
        updateClipUseCase: UpdateClipUseCase
    ) {
        state = BehaviorRelay(value: State(
            type: .edit,
            urlInputText: clip.urlMetadata.url.absoluteString,
            memoText: clip.memo,
            memoLimit: "\(clip.memo.count)/100",
            clip: clip
        ))
        self.checkURLValidityUseCase = checkURLValidityUseCase
        self.parseURLMetadataUseCase = parseURLMetadataUseCase
        self.fetchFolderUseCase = fetchFolderUseCase
        self.createClipUseCase = createClipUseCase
        self.updateClipUseCase = updateClipUseCase
        bind()
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .editURLInputTextField(let urlText):
            return .merge(
                .just(.updateURLInputText(urlText)),
                .fromAsync {
                    try await self.checkURLValidityUseCase.execute(urlString: urlText).get()
                }
                .map { .updateValidURL($0) }
                .catchAndReturn(.updateValidURL(false)),
                .fromAsync {
                    try await self.parseURLMetadataUseCase.execute(urlString: urlText).get()
                }
                .map { .updateURLMetadata(self.toURLMetaDisplay(entity: $0)) }
                .catchAndReturn(.updateURLMetadata(nil))
            )
        case .editMomo(let memoText):
            return .just(.updateMemo(memoText))
        case .folderViewTapped:
            return .just(.updateFolderViewTapped(true))
        case .editFolder(let newFolder):
            return .just(.updateCurrentFolder(newFolder))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .updateURLInputText(let urlText):
            newState.urlInputText = urlText
            if urlText.isEmpty {
                newState.isHiddenURLValidationStackView = true
            }
        case .updateMemo(let memoText):
            newState.memoText = memoText
            newState.memoLimit = "\(memoText.count)/100"
        case .updateValidURL(let result):
            newState.isURLValid = result
            newState.urlValidationImageName = result ? "checkmark.circle.fill" : "exclamationmark.triangle.fill"
            newState.urlValidationLabelText = result ? "올바른 URL 입니다." : "올바르지 않은 URL 입니다."
            if !state.urlInputText.isEmpty {
                newState.isHiddenURLValidationStackView = false
            }
        case .updateURLMetadata(let urlMetaDisplay):
            newState.urlMetadata = urlMetaDisplay
            newState.isHiddenURLMetadataStackView = urlMetaDisplay == nil
        case .updateFolderViewTapped(let value):
            newState.isFolderViewTapped = value
        case .updateCurrentFolder(let newFolder):
            newState.currentFolder = newFolder
        }
        return newState
    }
}

private extension EditClipViewModel {
    func toURLMetaDisplay(entity: ParsedURLMetadata) -> URLMetadataDisplay {
        URLMetadataDisplay(
            url: entity.url,
            title: entity.title,
            thumbnailImageURL: entity.thumbnailImageURL
        )
    }
}

extension Observable {
    static func fromAsync<T>(_ block: @escaping () async throws -> T) -> Observable<T> {
        Single.create { emitter in
            Task {
                do {
                    let result = try await block()
                    emitter(.success(result))
                } catch {
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
        .asObservable()
    }
}
