import Foundation
import ReactorKit

final class EditClipReactor: Reactor {
    enum EditClipReactorType {
        case edit
        case create
    }

    enum Action {
        case viewDidAppear
        case editURLTextField(String)
        case validifyURL(String)
        case editingURLTextField
        case editMemo(String)
        case tapFolderView
        case editFolder(Folder?)
        case saveClip
        case fetchFolder
        case disappearFolderSelectorView
    }

    enum Mutation {
        case updateURLString(String)
        case updateMemo(String)
        case updateIsValidURL(ParseResultType)
        case updateURLMetadata(URLMetadataDisplay?)
        case updateIsTappedFolderView(Bool)
        case updateCurrentFolder(Folder?)
        case updateIsSuccessedEditClip(Bool)
        case updateIsLoading(Bool)
        case updateShouldReadPastedboardURL(Bool)
    }

    struct State {
        var type: EditClipReactorType
        var clip: Clip?
        var currentFolder: Folder?
        var urlString: String = ""
        var memoText: String = ""
        var urlMetadataDisplay: URLMetadataDisplay?
        var urlValidationResult: ParseResultType?
        var isLoading = false
        var isTappedFolderView: Bool = false
        var isSuccessedEditClip: Bool = false
        var shouldReadPastedboardURL: Bool = false

        var navigationTitle: String {
            type == .create ? "클립 추가" : "클립 수정"
        }
        var memoLimit: String {
            "\(memoText.count) / 100"
        }
        var isURLValid: Bool {
            guard let result = urlValidationResult else { return false }
            return result != .invalid
        }
        var isHiddenURLMetadataStackView: Bool {
            urlMetadataDisplay?.thumbnailImageURL == nil && urlMetadataDisplay?.screenshotImageData == nil
        }
        var isHiddenURLValidationStackView: Bool {
            urlString.isEmpty
        }

        var urlTextFieldBorderColor: ColorResource {
            guard !urlString.isEmpty, let result = urlValidationResult else { return .dialogueStroke }
            switch result {
            case .valid:
                return .appPrimary
            case .validWithWarning:
                return .yellow600
            case .invalid:
                return .red600
            }
        }
        var urlValidationLabelText: String {
            if isLoading { return "URL 분석 중..." }
            guard let result = urlValidationResult else { return "" }

            switch result {
            case .valid:
                return "올바른 URL 입니다."
            case .validWithWarning:
                return "올바른 URL이지만, 미리보기를 불러 올 수 없습니다."
            case .invalid:
                return "올바르지 않은 URL 입니다."
            }
        }

        var urlValidationImageResource: ImageResource? {
            guard !isLoading, let result = urlValidationResult else {
                return .none
            }
            switch result {
            case .valid:
                return .checkBlue
            case .invalid:
                return .xCircleRed
            case .validWithWarning:
                return .infoYellow
            }
        }
    }

    var initialState: State

    private let parseURLUseCase: ParseURLUseCase
    private let fetchFolderUseCase: FetchFolderUseCase
    private let createClipUseCase: CreateClipUseCase
    private let updateClipUseCase: UpdateClipUseCase

    init(
        currentFolder: Folder? = nil,
        parseURLUseCase: ParseURLUseCase,
        fetchFolderUseCase: FetchFolderUseCase,
        createClipUseCase: CreateClipUseCase,
        updateClipUseCase: UpdateClipUseCase
    ) {
        self.initialState = State(
            type: .create,
            currentFolder: currentFolder
        )
        self.parseURLUseCase = parseURLUseCase
        self.fetchFolderUseCase = fetchFolderUseCase
        self.createClipUseCase = createClipUseCase
        self.updateClipUseCase = updateClipUseCase
    }

    init(
        clip: Clip,
        parseURLUseCase: ParseURLUseCase,
        fetchFolderUseCase: FetchFolderUseCase,
        createClipUseCase: CreateClipUseCase,
        updateClipUseCase: UpdateClipUseCase
    ) {
        self.initialState = State(
            type: .edit,
            clip: clip,
            urlString: clip.url.absoluteString,
            memoText: clip.memo
        )
        self.parseURLUseCase = parseURLUseCase
        self.fetchFolderUseCase = fetchFolderUseCase
        self.createClipUseCase = createClipUseCase
        self.updateClipUseCase = updateClipUseCase
    }

    func mutate(action: Action) -> Observable<Mutation> {
        print("\(Self.self) \(action)")
        switch action {
        case .editURLTextField(let text):
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            return .just(.updateURLString(trimmed))
        case .validifyURL(let text):
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            return .fromAsync { [weak self] in
                guard let self else { return Observable<Mutation>.empty() }
                let (metadata, isValidURL) = try await parseURLUseCase.execute(urlString: trimmed).get()
                let clipValidType: ParseResultType
                switch (metadata, isValidURL) {
                case (.some, true):
                    clipValidType = .valid
                case (nil, true):
                    clipValidType = .validWithWarning
                case (_, false):
                    clipValidType = .invalid
                }
                return .merge(
                    .just(Mutation.updateURLMetadata(URLMetadataDisplayMapper.map(urlMetaData: metadata))),
                    .just(Mutation.updateIsValidURL(clipValidType))
                )
            }
            .flatMap { $0 }
            .catch { error in
                if let urlValidationError = error as? URLValidationError {
                    switch urlValidationError {
                    case .badURL:
                        return Observable.merge(
                            .just(Mutation.updateURLMetadata(nil)),
                            .just(Mutation.updateIsValidURL(.invalid))
                        )
                    case .unknown:
                        return .empty()
                    default:
                        return Observable.merge(
                            .just(Mutation.updateURLMetadata(self.makeURLMetaDisplayOnlyURL(urlString: self.currentState.urlString))),
                            .just(Mutation.updateIsValidURL(.validWithWarning))
                        )
                    }
                }
                return .empty()
            }
        case .editingURLTextField:
            return .just(.updateIsLoading(true))
        case .editMemo(let text):
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            return .just(.updateMemo(trimmed))
        case .tapFolderView:
            return .just(.updateIsTappedFolderView(true))
        case .editFolder(let newFolder):
            return .just(.updateCurrentFolder(newFolder))
        case .saveClip:
            switch currentState.type {
            case .edit:
                print("\(Self.self) edit clip")
                guard let clip = currentState.clip else { return .empty() }
                guard let urlMetadataDisplay = currentState.urlMetadataDisplay else { return .empty() }

                let newClip = Clip(
                    id: clip.id,
                    folderID: currentState.currentFolder?.id,
                    url: urlMetadataDisplay.url,
                    title: urlMetadataDisplay.title,
                    subtitle: urlMetadataDisplay.description,
                    memo: currentState.memoText,
                    thumbnailImageURL: urlMetadataDisplay.thumbnailImageURL,
                    screenshotData: urlMetadataDisplay.screenshotImageData,
                    createdAt: clip.createdAt,
                    lastVisitedAt: clip.url != urlMetadataDisplay.url ? nil : clip.lastVisitedAt,
                    updatedAt: Date.now,
                    deletedAt: clip.deletedAt,
                )
                return .fromAsync {
                    try await self.updateClipUseCase.execute(clip: newClip).get()
                }
                .map { .updateIsSuccessedEditClip(true) }
                .catchAndReturn(.updateIsSuccessedEditClip(false))
            case .create:
                print("\(Self.self) save clip")
                guard let urlMetadataDisplay = currentState.urlMetadataDisplay else { return .empty() }

                let newClip = Clip(
                    id: UUID(),
                    folderID: currentState.currentFolder?.id,
                    url: urlMetadataDisplay.url,
                    title: urlMetadataDisplay.title,
                    subtitle: urlMetadataDisplay.description,
                    memo: currentState.memoText,
                    thumbnailImageURL: urlMetadataDisplay.thumbnailImageURL,
                    screenshotData: urlMetadataDisplay.screenshotImageData,
                    createdAt: Date.now,
                    lastVisitedAt: nil,
                    updatedAt: Date.now,
                    deletedAt: nil,
                )
                return .fromAsync {
                    try await self.createClipUseCase.execute(newClip).get()
                }
                .map { .updateIsSuccessedEditClip(true) }
                .catchAndReturn(.updateIsSuccessedEditClip(false))
            }
        case .fetchFolder:
            guard let clip = currentState.clip,
                  let folderID = clip.folderID else { return .empty() }
            return .fromAsync {
                try await self.fetchFolderUseCase.execute(id: folderID).get()
            }
            .map { .updateCurrentFolder($0) }
            .catchAndReturn(.updateCurrentFolder(nil))
        case .disappearFolderSelectorView:
            return .just(.updateIsTappedFolderView(false))
        case .viewDidAppear:
            return .just(.updateShouldReadPastedboardURL(true))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .updateURLString(let text):
            newState.urlString = text
        case .updateMemo(let text):
            newState.memoText = text
        case .updateIsValidURL(let type):
            newState.urlValidationResult = type
            newState.isLoading = false
        case .updateURLMetadata(let urlMetaDisplay):
            newState.urlMetadataDisplay = urlMetaDisplay
        case .updateIsTappedFolderView(let value):
            newState.isTappedFolderView = value
        case .updateCurrentFolder(let newFolder):
            newState.currentFolder = newFolder
        case .updateIsSuccessedEditClip(let value):
            newState.isSuccessedEditClip = value
        case .updateIsLoading(let value):
            newState.isLoading = value
        case .updateShouldReadPastedboardURL(let value):
            newState.shouldReadPastedboardURL = value
        }
        return newState
    }
}

private extension EditClipReactor {
    func makeURLMetaDisplayOnlyURL(urlString: String) -> URLMetadataDisplay? {
        guard let url = URL(string: urlString) else { return nil }
        return URLMetadataDisplay(
            url: url,
            title: url.absoluteString,
            description: "내용 없음",
            thumbnailImageURL: nil,
            screenshotImageData: nil
        )
    }
}
