import Foundation
import ReactorKit

final class EditClipReactor: Reactor {
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
        case updateIsValidURL(Bool)
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
                guard let metadata else { return Observable<Mutation>.empty() }
                return Observable.merge(
                    .just(Mutation.updateIsValidURL(isValidURL)),
                    .just(Mutation.updateURLMetadata(toURLMetaDisplay(entity: metadata)))
                )
            }
            .flatMap { $0 }
            .catch { _ in
                Observable.merge(
                    .just(Mutation.updateIsValidURL(false)),
                    .just(Mutation.updateURLMetadata(nil))
                )
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
                        createdAt: clip.createdAt,
                        updatedAt: clip.urlMetadata.url != urlMetadataDisplay.url ? Date() : clip.updatedAt,
                        deletedAt: clip.deletedAt
                    ),
                    memo: currentState.memoText,
                    lastVisitedAt: clip.urlMetadata.url != urlMetadataDisplay.url ? nil : clip.lastVisitedAt,
                    createdAt: clip.createdAt,
                    updatedAt: clip.memo != currentState.memoText ||
                    clip.urlMetadata.url != urlMetadataDisplay.url ||
                    clip.folderID != currentFolder.id ? Date() : clip.updatedAt,
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
        case .updateIsValidURL(let value):
            newState.isURLValid = value
            newState.urlValidationImageName = value ? "CheckBlue" : "XRed"
            newState.urlValidationLabelText = value ? "올바른 URL 입니다." : "올바르지 않은 URL 입니다."
            newState.isLoading = false

            if currentState.urlString.isEmpty {
                newState.urlTextFieldBorderColor = .black900
            } else {
                newState.urlTextFieldBorderColor = value ? .blue600 : .red600
            }
        case .updateURLMetadata(let urlMetaDisplay):
            newState.urlMetadataDisplay = urlMetaDisplay
            newState.isHiddenURLMetadataStackView = urlMetaDisplay == nil
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
    func toURLMetaDisplay(entity: ParsedURLMetadata) -> URLMetadataDisplay {
        URLMetadataDisplay(
            url: entity.url,
            title: entity.title,
            thumbnailImageURL: entity.thumbnailImageURL,
            screenshotImageData: entity.screenshotData
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
