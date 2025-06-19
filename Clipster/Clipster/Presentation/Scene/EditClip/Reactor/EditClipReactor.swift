import Foundation
import ReactorKit

final class EditClipReactor: Reactor {
    enum ClipValidType {
        case valid
        case validWithWarning
        case invalid
    }

    enum EditClipReactorType {
        case edit
        case create
        case shareExtension
    }

    enum Action {
        case editURLTextField(String)
        case editingURLTextField
        case editMemo(String)
        case tapFolderView
        case editFolder(Folder?)
        case saveClip
        case fetchFolder
        case fetchTopLevelFolder
        case disappearFolderSelectorView
    }

    enum Mutation {
        case updateURLString(String)
        case updateMemo(String)
        case updateIsValidURL(ClipValidType)
        case updateURLMetadata(URLMetadataDisplay?)
        case updateIsTappedFolderView(Bool)
        case updateCurrentFolder(Folder?)
        case updateIsSuccessedEditClip(Bool)
        case updateIsLoading(Bool)
    }

    struct State {
        var type: EditClipReactorType
        var clip: Clip?
        var currentFolder: Folder?
        var navigationTitle: String
        var urlString: String
        var memoText: String = ""
        var memoLimit: String = "0 / 100"
        var urlValidationImageName: String?
        var urlValidationLabelText: String = ""
        var urlMetadataDisplay: URLMetadataDisplay?
        var urlTextFieldBorderColor: ColorResource = .black900
        var isLoading = false
        var isHiddenURLMetadataStackView = true
        var isHiddenURLValidationStackView = true
        var isURLValid = false
        var isTappedFolderView: Bool = false
        var isSuccessedEditClip: Bool = false
    }

    var initialState: State

    private let parseURLUseCase: ParseURLUseCase
    private let fetchFolderUseCase: FetchFolderUseCase
    private let fetchTopLevelFoldersUseCase: FetchTopLevelFoldersUseCase
    private let createClipUseCase: CreateClipUseCase
    private let updateClipUseCase: UpdateClipUseCase

    init(
        urlText: String = "",
        currentFolder: Folder? = nil,
        parseURLUseCase: ParseURLUseCase,
        fetchFolderUseCase: FetchFolderUseCase,
        fetchTopLevelFoldersUseCase: FetchTopLevelFoldersUseCase,
        createClipUseCase: CreateClipUseCase,
        updateClipUseCase: UpdateClipUseCase
    ) {
        self.initialState = State(
            type: urlText.isEmpty ? .create : .shareExtension,
            currentFolder: currentFolder,
            navigationTitle: "클립 추가",
            urlString: urlText,
        )
        self.parseURLUseCase = parseURLUseCase
        self.fetchFolderUseCase = fetchFolderUseCase
        self.fetchTopLevelFoldersUseCase = fetchTopLevelFoldersUseCase
        self.createClipUseCase = createClipUseCase
        self.updateClipUseCase = updateClipUseCase
    }

    init(
        clip: Clip,
        parseURLUseCase: ParseURLUseCase,
        fetchFolderUseCase: FetchFolderUseCase,
        fetchTopLevelFoldersUseCase: FetchTopLevelFoldersUseCase,
        createClipUseCase: CreateClipUseCase,
        updateClipUseCase: UpdateClipUseCase
    ) {
        self.initialState = State(
            type: .edit,
            clip: clip,
            navigationTitle: "클립 수정",
            urlString: clip.urlMetadata.url.absoluteString,
            memoText: clip.memo,
            memoLimit: "\(clip.memo.count) / 100"
        )
        self.parseURLUseCase = parseURLUseCase
        self.fetchFolderUseCase = fetchFolderUseCase
        self.fetchTopLevelFoldersUseCase = fetchTopLevelFoldersUseCase
        self.createClipUseCase = createClipUseCase
        self.updateClipUseCase = updateClipUseCase
    }

    func mutate(action: Action) -> Observable<Mutation> {
        print("\(Self.self) \(action)")
        switch action {
        case .editURLTextField(let text):
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            let updateURLText = Observable.just(Mutation.updateURLString(trimmed))
            let parsedURL = Observable<Mutation>.fromAsync { [weak self] in
                guard let self else { return Observable<Mutation>.empty() }
                let (metadata, isValidURL) = try await parseURLUseCase.execute(urlString: trimmed).get()

                let clipValidType: ClipValidType
                switch (metadata, isValidURL) {
                case (.some, true):
                    clipValidType = .valid
                case (nil, true):
                    clipValidType = .validWithWarning
                case (_, false):
                    clipValidType = .invalid
                }

                return Observable.merge(
                    .just(Mutation.updateURLMetadata(toURLMetaDisplay(entity: metadata))),
                    .just(Mutation.updateIsValidURL(clipValidType)),
                )
            }
            .flatMap { $0 }
            .catch { error in
                print(error)
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
                            .just(Mutation.updateURLMetadata(nil)),
                            .just(Mutation.updateIsValidURL(.validWithWarning))
                        )
                    }
                }
                return .empty()
            }
            return Observable.merge(updateURLText, parsedURL)
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
                guard let currentFolder = currentState.currentFolder else { return .empty() }
                guard let urlMetadataDisplay = currentState.urlMetadataDisplay else { return .empty() }

                let newClip = Clip(
                    id: clip.id,
                    folderID: currentFolder.id,
                    urlMetadata: URLMetadata(
                        url: urlMetadataDisplay.url,
                        title: urlMetadataDisplay.title,
                        thumbnailImageURL: urlMetadataDisplay.thumbnailImageURL,
                        screenshotData: urlMetadataDisplay.screenshotImageData,
                        createdAt: clip.createdAt,
                        updatedAt: Date(),
                        deletedAt: clip.deletedAt
                    ),
                    memo: currentState.memoText,
                    lastVisitedAt: clip.urlMetadata.url != urlMetadataDisplay.url ? nil : clip.lastVisitedAt,
                    createdAt: clip.createdAt,
                    updatedAt: Date(),
                    deletedAt: clip.deletedAt
                )
                return .fromAsync {
                    try await self.updateClipUseCase.execute(clip: newClip).get()
                }
                .map { .updateIsSuccessedEditClip(true) }
                .catchAndReturn(.updateIsSuccessedEditClip(false))
            case .create, .shareExtension:
                print("\(Self.self) save clip")
                guard let currentFolder = currentState.currentFolder else { return .empty() }
                guard let urlMetadata = currentState.urlMetadataDisplay else { return .empty() }

                let newClip = Clip(
                    id: UUID(),
                    folderID: currentFolder.id,
                    urlMetadata: URLMetadata(
                        url: urlMetadata.url,
                        title: urlMetadata.title,
                        thumbnailImageURL: urlMetadata.thumbnailImageURL,
                        screenshotData: urlMetadata.screenshotImageData,
                        createdAt: Date(),
                        updatedAt: Date(),
                        deletedAt: nil
                    ),
                    memo: currentState.memoText,
                    lastVisitedAt: nil,
                    createdAt: Date(),
                    updatedAt: Date(),
                    deletedAt: nil
                )
                return .fromAsync {
                    try await self.createClipUseCase.execute(newClip).get()
                }
                .map { .updateIsSuccessedEditClip(true) }
                .catchAndReturn(.updateIsSuccessedEditClip(false))
            }
        case .fetchFolder:
            guard let clip = currentState.clip else { return .empty() }
            return .fromAsync {
                try await self.fetchFolderUseCase.execute(id: clip.folderID).get()
            }
            .map { .updateCurrentFolder($0) }
            .catchAndReturn(.updateCurrentFolder(nil))
        case .fetchTopLevelFolder:
            return .fromAsync { [weak self] in
                try? await self?.fetchTopLevelFoldersUseCase.execute().get()
            }
            .compactMap { $0 }
            .map { $0.max { $0.updatedAt < $1.updatedAt } }
            .map { .updateCurrentFolder($0) }
            .catchAndReturn(.updateCurrentFolder(nil))
        case .disappearFolderSelectorView:
            return .just(.updateIsTappedFolderView(false))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .updateURLString(let text):
            newState.urlString = text
            if text.isEmpty {
                newState.isHiddenURLValidationStackView = true
            }
        case .updateMemo(let text):
            newState.memoText = text
            newState.memoLimit = "\(text.count) / 100"
        case .updateIsValidURL(let type):
            switch type {
            case .valid:
                newState.isURLValid = true
                newState.urlValidationImageName = "CheckBlue"
                newState.urlValidationLabelText = "올바른 URL 입니다."
                if !currentState.urlString.isEmpty {
                    newState.urlTextFieldBorderColor = .blue600
                }
            case .validWithWarning:
                newState.isURLValid = true
                newState.urlValidationImageName = "InfoYellow"
                newState.urlValidationLabelText = "올바른 URL이지만, 미리보기를 불러 올 수 없습니다."
                if !currentState.urlString.isEmpty {
                    newState.urlTextFieldBorderColor = .yellow600
                }
            case .invalid:
                newState.isURLValid = false
                newState.urlValidationImageName = "XCircleRed"
                newState.urlValidationLabelText = "올바르지 않은 URL 입니다."
                if !currentState.urlString.isEmpty {
                    newState.urlTextFieldBorderColor = .red600
                }
            }
            newState.isLoading = false

            if currentState.urlString.isEmpty {
                newState.urlTextFieldBorderColor = .black900
            }
        case .updateURLMetadata(let urlMetaDisplay):
            newState.urlMetadataDisplay = urlMetaDisplay
            newState.isHiddenURLMetadataStackView = urlMetaDisplay?.title == nil
        case .updateIsTappedFolderView(let value):
            newState.isTappedFolderView = value
        case .updateCurrentFolder(let newFolder):
            newState.currentFolder = newFolder
        case .updateIsSuccessedEditClip(let value):
            newState.isSuccessedEditClip = value
        case .updateIsLoading(let value):
            newState.isLoading = value
            newState.urlValidationLabelText = "URL 분석 중..."
            newState.urlValidationImageName = nil
            newState.isHiddenURLValidationStackView = false
        }
        return newState
    }
}

private extension EditClipReactor {
    func toURLMetaDisplay(entity: ParsedURLMetadata?) -> URLMetadataDisplay? {
        entity.map {
            URLMetadataDisplay(
                url: $0.url,
                title: $0.title,
                thumbnailImageURL: $0.thumbnailImageURL,
                screenshotImageData: $0.screenshotData
            )
        }
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
