import Foundation
import RxRelay
import RxSwift

final class EditClipViewModel: ViewModel {
    enum Action {
        case editURLInputTextField(String)
        case editMomo(String)
    }

    enum Mutation {
        case updateURLInputText(String)
        case updateMemo(String)
        case updateValidURL(Bool)
        case updateURLMetadata(URLMetadataDisplay?)
    }

    struct State {
        var urlInputText: String
        var isHiddenURLMetadataStackView = true
        var isHiddenURLValidationStackView = true
        var memoText: String
        var memoLimit: String
        var isURLValid = false
        var urlValidationImageName: String = ""
        var urlValidationLabelText: String = ""
        var urlMetadata: URLMetadataDisplay?
    }

    var state: BehaviorRelay<State>
    var action = PublishRelay<Action>()
    var disposeBag = DisposeBag()

    private let checkURLValidityUseCase: CheckURLValidityUseCase
    private let parseURLMetadataUseCase: ParseURLMetadataUseCase

    init(
        urlText: String = "",
        memoText: String = "",
        checkURLValidityUseCase: CheckURLValidityUseCase,
        parseURLMetadataUseCase: ParseURLMetadataUseCase
    ) {
        state = BehaviorRelay(value: State(
            urlInputText: urlText,
            memoText: memoText,
            memoLimit: "\(memoText)/100"
        ))
        self.checkURLValidityUseCase = checkURLValidityUseCase
        self.parseURLMetadataUseCase = parseURLMetadataUseCase
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
