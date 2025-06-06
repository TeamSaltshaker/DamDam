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
        var urlInputText: String = ""
        var isEmptyURLInput: Bool = false
        var isHiddenURLMetadataStackView = false
        var isHiddenURLValidationStackView = false
        var memoText: String = ""
        var memoLimit: String = "0/100"
    }

    var state: BehaviorRelay<State>
    var action = PublishRelay<Action>()
    var disposeBag = DisposeBag()

    init() {
        state = BehaviorRelay(value: State())
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
            newState.isEmptyURLInput = newState.urlInputText.isEmpty
            newState.isHiddenURLMetadataStackView = newState.urlInputText.isEmpty
            newState.isHiddenURLValidationStackView = newState.urlInputText.isEmpty
        case .updateMemo(let memoText):
            newState.memoText = memoText
            newState.memoLimit = "\(memoText.count)/100"
        }
        return newState
    }
}
