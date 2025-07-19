import Foundation
import ReactorKit

final class ShareReactor: Reactor {
    enum Action {
        case viewWillAppear
        case extractedExtensionItems([NSExtensionItem])
        case editURLTextField(String)
        case validifyURL(String)
        case editingURLTextField
        case editMemo(String)
        case tapFolderView
        case editFolder(Folder?)
        case saveClip
        case disappearFolderSelectorView
    }

    enum Mutation {
        case updateIsReadyExtractURL(Bool)
        case updateURLString(String)
        case updateURLMetadata(URLMetadataDisplay?)
        case updateIsValidURL(ClipValidType)
        case updateIsLoading(Bool)
        case updateMemo(String)
        case updateIsTappedFolderView(Bool)
        case updateCurrentFolder(Folder?)
        case updateIsSuccessedEditClip(Bool)
    }

    struct State {
        var currentFolder: Folder?
        var urlString: String = ""
        var memoText: String = ""
        var isReadyToExtractURL = false
        var urlMetadataDisplay: URLMetadataDisplay?
        var urlValidationResult: ClipValidType?
        var isLoading = false
        var isTappedFolderView: Bool = false
        var isSuccessedEditClip: Bool = false

        var memoLimit: String {
            "\(memoText.count) / 100"
        }
        var isURLValid: Bool {
            guard let result = urlValidationResult else { return false }
            return result != .invalid
        }
        var isHiddenURLMetadataStackView: Bool {
            urlMetadataDisplay?.thumbnailImageURL == nil &&
            urlMetadataDisplay?.screenshotImageData == nil
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
    private let createClipUseCase: CreateClipUseCase
    private let extractExtensionContextUseCase: ExtractExtensionContextUseCase

    init(
        parseURLUseCase: ParseURLUseCase,
        createClipUseCase: CreateClipUseCase,
        extractExtensionContextUseCase: ExtractExtensionContextUseCase
    ) {
        initialState = State()

        self.parseURLUseCase = parseURLUseCase
        self.createClipUseCase = createClipUseCase
        self.extractExtensionContextUseCase = extractExtensionContextUseCase
    }

    func mutate(action: Action) -> Observable<Mutation> {
        print("\(Self.self) action: \(action)")
        switch action {
        case .viewWillAppear:
            return .just(.updateIsReadyExtractURL(true))
        case .extractedExtensionItems(let extensionItems):
            return .fromAsync { [weak self] in
                guard let self else { return Observable<Mutation>.empty() }
                let url = try await extractExtensionContextUseCase.execute(extensionItems: extensionItems).get()
                return .just(.updateURLString(url.absoluteString))
            }
            .flatMap { $0 }
            .catch { _ in
                .empty()
            }
        case .editURLTextField(let text):
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            return .just(.updateURLString(trimmed))
        case .validifyURL(let text):
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            return .fromAsync { [weak self] in
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
            return .fromAsync { [weak self] in
                guard let self else { return Observable<Mutation>.empty() }
                try await createClipUseCase.execute(newClip).get()
                return .just(.updateIsSuccessedEditClip(true))
            }
            .flatMap { $0 }
            .catch { _ in
                .just(.updateIsSuccessedEditClip(false))
            }
        case .disappearFolderSelectorView:
            return .just(.updateIsTappedFolderView(false))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case .updateIsReadyExtractURL(let value):
            newState.isReadyToExtractURL = value
        case .updateURLString(let text):
            newState.urlString = text
        case .updateMemo(let text):
            newState.memoText = text
        case .updateIsValidURL(let type):
            newState.urlValidationResult = type
            newState.isLoading = false
        case .updateURLMetadata(let urlMetaDisplay):
            newState.urlMetadataDisplay = urlMetaDisplay
        case .updateIsLoading(let value):
            newState.isLoading = value
        case .updateIsTappedFolderView(let value):
            newState.isTappedFolderView = value
        case .updateCurrentFolder(let newFolder):
            newState.currentFolder = newFolder
        case .updateIsSuccessedEditClip(let value):
            newState.isSuccessedEditClip = value
        }

        return newState
    }
}

private extension ShareReactor {
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
