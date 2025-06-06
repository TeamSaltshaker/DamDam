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
    }

    struct State {
        var urlInputText: String
        var isHiddenURLMetadataStackView = false
        var isHiddenURLValidationStackView = false
        var memoText: String
        var memoLimit: String
    }

    var state: BehaviorRelay<State>
    var action = PublishRelay<Action>()
    var disposeBag = DisposeBag()

    init(urlText: String = "", memoText: String = "") {
        state = BehaviorRelay(value: State(
            urlInputText: urlText,
            memoText: memoText,
            memoLimit: "\(memoText)/100"
        ))
        bind()
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .editURLInputTextField(let urlText):
            return .just(.updateURLInputText(urlText))
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
        }
        return newState
    }
}
