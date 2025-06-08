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
    }

    struct State {
        var urlInputText: String
        var isHiddenURLMetadataStackView = false
        var isHiddenURLValidationStackView = false
        var memoText: String
        var memoLimit: String
        var isURLValid = false
        var urlValidationImageName: String = ""
        var urlValidationLabelText: String = ""
    }

    var state: BehaviorRelay<State>
    var action = PublishRelay<Action>()
    var disposeBag = DisposeBag()

    private let checkURLValidityUseCase: CheckURLValidityUseCase

    init(
        urlText: String = "",
        memoText: String = "",
        checkURLValidityUseCase: CheckURLValidityUseCase
    ) {
        state = BehaviorRelay(value: State(
            urlInputText: urlText,
            memoText: memoText,
            memoLimit: "\(memoText)/100"
        ))
        self.checkURLValidityUseCase = checkURLValidityUseCase
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
                .map { Mutation.updateValidURL($0) }
                .catchAndReturn(.updateValidURL(false))
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
            newState.isHiddenURLMetadataStackView = newState.urlInputText.isEmpty
            newState.isHiddenURLValidationStackView = newState.urlInputText.isEmpty
        case .updateMemo(let memoText):
            newState.memoText = memoText
            newState.memoLimit = "\(memoText.count)/100"
        case .updateValidURL(let result):
            newState.isURLValid = result
            newState.urlValidationImageName = result ? "checkmark.circle.fill" : "exclamationmark.triangle.fill"
            newState.urlValidationLabelText = result ? "올바른 URL 입니다." : "올바르지 않은 URL 입니다."
        }
        return newState
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
